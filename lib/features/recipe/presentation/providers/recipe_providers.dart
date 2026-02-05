import 'dart:async';
import 'dart:convert';

import 'package:my_recipe_memo/core/constants/app_constants.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/recipe/data/recipe_repository.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recipe_providers.g.dart';

enum SortOrder { newestFirst, oldestFirst }

class RecipeFilter {
  const RecipeFilter({
    this.categories = const [],
    this.sortOrder = SortOrder.newestFirst,
    this.favoritesOnly = false,
  });

  final List<RecipeCategory> categories; // 空なら全カテゴリ
  final SortOrder sortOrder;
  final bool favoritesOnly;

  RecipeFilter copyWith({
    List<RecipeCategory>? categories,
    SortOrder? sortOrder,
    bool? favoritesOnly,
  }) {
    return RecipeFilter(
      categories: categories ?? this.categories,
      sortOrder: sortOrder ?? this.sortOrder,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

class SavedFilter {
  const SavedFilter({required this.name, required this.filter});
  final String name;
  final RecipeFilter filter;

  Map<String, dynamic> toJson() => {
    'name': name,
    'categories': filter.categories.map((c) => c.title).toList(),
    'sortOrder': filter.sortOrder.name,
    'favoritesOnly': filter.favoritesOnly,
  };

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    final categoryTitles = (json['categories'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final categories = RecipeCategory.values
        .where((c) => categoryTitles.contains(c.title))
        .toList();
    final sortOrderString = json['sortOrder'] as String? ?? 'newestFirst';
    final sortOrder = SortOrder.values.firstWhere(
      (e) => e.name == sortOrderString,
      orElse: () => SortOrder.newestFirst,
    );
    final favoritesOnly = json['favoritesOnly'] as bool? ?? false;
    return SavedFilter(
      name: json['name'] as String,
      filter: RecipeFilter(
        categories: categories,
        sortOrder: sortOrder,
        favoritesOnly: favoritesOnly,
      ),
    );
  }
}

@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  // ユーザーの変更を監視して再構築する
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  return ref.watch(recipeRepositoryProvider).watchRecipes();
}

@riverpod
class FavoriteOverrides extends _$FavoriteOverrides {
  @override
  Map<String, bool> build() => const {};

  void set(String recipeId, bool isFavorite) {
    state = {...state, recipeId: isFavorite};
  }

  void remove(String recipeId) {
    final next = {...state}..remove(recipeId);
    state = next;
  }
}

@riverpod
Future<List<Recipe>> effectiveRecipes(Ref ref) async {
  final recipes = await ref.watch(recipesProvider.future);
  final overrides = ref.watch(favoriteOverridesProvider);

  return recipes
      .map(
        (recipe) => recipe.id == null
            ? recipe
            : recipe.copyWith(
                isFavorite: overrides[recipe.id!] ?? recipe.isFavorite,
              ),
      )
      .toList(growable: false);
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() {
    return '';
  }

  void onChange(String query) {
    state = query;
  }
}

@riverpod
class RecipeFilterState extends _$RecipeFilterState {
  static const _prefsKey = 'recipe_filter_presets';
  bool _restored = false;

  @override
  (RecipeFilter filter, List<SavedFilter> presets) build() {
    _restorePresets();
    return (const RecipeFilter(), const <SavedFilter>[]);
  }

  void setFilter(RecipeFilter filter) {
    state = (filter, state.$2);
  }

  void savePreset(String name) {
    final currentFilter = state.$1;
    final presets = [...state.$2];
    presets.removeWhere((p) => p.name == name);
    presets.insert(0, SavedFilter(name: name, filter: currentFilter));
    if (presets.length > RecipeConstants.maxFilterPresets) {
      presets.removeLast();
    }
    state = (currentFilter, presets);
    _persistPresets(presets);
  }

  void applyPreset(SavedFilter preset) {
    state = (preset.filter, state.$2);
  }

  void saveCurrentWithGeneratedName() {
    final now = DateTime.now();
    final name =
        '${now.year.toString().padLeft(4, '0')}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    savePreset(name);
  }

  Future<void> _persistPresets(List<SavedFilter> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = presets
        .map((p) => jsonEncode(p.toJson()))
        .toList(growable: false);
    await prefs.setStringList(_prefsKey, encoded);
  }

  Future<void> _restorePresets() async {
    if (_restored) return;
    _restored = true;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey);
    if (stored == null) return;
    final restored = stored
        .map((e) => SavedFilter.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
    state = (state.$1, restored);
  }
}

@riverpod
Future<List<Recipe>> filteredRecipes(Ref ref) async {
  final recipes = await ref.watch(effectiveRecipesProvider.future);
  final query = ref.watch(searchQueryProvider);
  final filterState = ref.watch(recipeFilterStateProvider);
  final filter = filterState.$1;

  var working = [...recipes];

  // カテゴリ絞り込み
  if (filter.categories.isNotEmpty) {
    final categorySet = filter.categories.toSet();
    working = working
        .where((r) => categorySet.contains(r.category))
        .toList(growable: false);
  }

  // 検索クエリ
  if (query.isNotEmpty) {
    working = working
        .where(
          (recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList(growable: false);
  }

  // お気に入りのみ
  if (filter.favoritesOnly) {
    working = working.where((r) => r.isFavorite).toList(growable: false);
  }

  // 並び替え
  working.sort((a, b) {
    final compare = a.createdAt.compareTo(b.createdAt);
    return filter.sortOrder == SortOrder.newestFirst ? -compare : compare;
  });

  return working;
}

@riverpod
class FavoriteController extends _$FavoriteController {
  static const _remoteSyncTimeout = Duration(seconds: 8);

  @override
  void build() {}

  Future<void> toggleFavorite(Recipe recipe) async {
    final recipeId = recipe.id;
    if (recipeId == null) {
      return;
    }

    final overridesNotifier = ref.read(favoriteOverridesProvider.notifier);
    final overrides = ref.read(favoriteOverridesProvider);
    final current = overrides[recipeId] ?? recipe.isFavorite;
    final toggled = !current;

    overridesNotifier.set(recipeId, toggled);

    try {
      await ref
          .read(recipeRepositoryProvider)
          .updateFavorite(recipeId: recipeId, isFavorite: toggled);
      await _waitRemoteSync(recipeId, toggled);
    } catch (_) {
      overridesNotifier.set(recipeId, current);
    }
  }

  Future<void> _waitRemoteSync(String recipeId, bool expected) async {
    final stream = ref.read(recipeRepositoryProvider).watchRecipes();
    try {
      await stream
          .firstWhere((recipes) {
            Recipe? matched;
            for (final recipe in recipes) {
              if (recipe.id == recipeId) {
                matched = recipe;
                break;
              }
            }
            return matched?.isFavorite == expected;
          })
          .timeout(_remoteSyncTimeout);
      ref.read(favoriteOverridesProvider.notifier).remove(recipeId);
    } on TimeoutException {
      // リモートが遅延しても UI を優先
    } catch (_) {
      // 無視してローカルの状態を保持
    }
  }
}
