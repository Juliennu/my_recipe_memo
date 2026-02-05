import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';
import 'package:my_recipe_memo/features/recipe/presentation/widgets/recipe_filter_sheet.dart';

class RecipeSearchField extends ConsumerWidget {
  const RecipeSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);
    final currentFilter = filterState.$1;
    final presets = filterState.$2;

    final hasAllCategories = Set<RecipeCategory>.from(
      currentFilter.categories,
    ).containsAll(RecipeCategory.values);
    final isDefaultFilter =
        (currentFilter.categories.isEmpty || hasAllCategories) &&
        currentFilter.sortOrder == SortOrder.newestFirst &&
        !currentFilter.favoritesOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildSearchField(ref),
          const SizedBox(width: 12),
          _buildFilterButton(
            context,
            ref,
            currentFilter,
            presets,
            isDefaultFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(WidgetRef ref) {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'レシピ名を検索',
          prefixIcon: const Icon(Icons.search, color: AppColors.text),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).onChange(value);
        },
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref,
    RecipeFilter currentFilter,
    List<SavedFilter> presets,
    bool isDefaultFilter,
  ) {
    return isDefaultFilter
        ? IconButton(
            onPressed: () =>
                showRecipeFilterSheet(context, ref, currentFilter, presets),
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.textSecondary,
            tooltip: 'フィルター',
          )
        : IconButton.filledTonal(
            onPressed: () =>
                showRecipeFilterSheet(context, ref, currentFilter, presets),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.9)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'フィルター',
          );
  }
}
