import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';
import 'package:my_recipe_memo/features/recipe/presentation/widgets/recipe_card.dart';
import 'package:my_recipe_memo/features/recipe/presentation/widgets/recipe_list_empty_view.dart';
import 'package:my_recipe_memo/features/recipe/presentation/widgets/recipe_search_field.dart';

class RecipeListPage extends ConsumerStatefulWidget {
  const RecipeListPage({super.key});

  @override
  ConsumerState<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends ConsumerState<RecipeListPage> {
  bool _wasCurrent = true;

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(filteredRecipesProvider);

    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrent && !_wasCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      });
    }
    _wasCurrent = isCurrent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const RecipeListEmptyView();
          }

          final groupedRecipes = <RecipeCategory, List<Recipe>>{};
          for (final recipe in recipes) {
            groupedRecipes.putIfAbsent(recipe.category, () => []).add(recipe);
          }

          final slivers = <Widget>[
            const SliverToBoxAdapter(child: RecipeSearchField()),
            const SliverPadding(padding: EdgeInsets.only(top: 8)),
          ];

          for (final category in RecipeCategory.values) {
            final categoryRecipes = groupedRecipes[category];
            if (categoryRecipes == null || categoryRecipes.isEmpty) continue;

            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.title,
                          style: AppTextStyles.size16Bold(
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        RecipeCard(recipe: categoryRecipes[index]),
                    childCount: categoryRecipes.length,
                  ),
                ),
              ),
            );
          }

          slivers.add(
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          );

          return CustomScrollView(slivers: slivers);
        },
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FocusScope.of(context).unfocus(); // 検索バーのフォーカスを外す
          context.push('/add');
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text(
          'レシピを追加',
          style: AppTextStyles.size14Bold(color: AppColors.white),
        ),
      ),
    );
  }
}
