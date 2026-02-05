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

class RecipeListPage extends ConsumerWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(filteredRecipesProvider);

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
      body: Column(
        children: [
          const RecipeSearchField(),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const RecipeListEmptyView();
                }

                // グループ化
                final groupedRecipes = <RecipeCategory, List<Recipe>>{};
                for (final recipe in recipes) {
                  groupedRecipes
                      .putIfAbsent(recipe.category, () => [])
                      .add(recipe);
                }

                // リストアイテムの作成
                final listItems = <dynamic>[];
                for (final category in RecipeCategory.values) {
                  final categoryRecipes = groupedRecipes[category];
                  if (categoryRecipes != null && categoryRecipes.isNotEmpty) {
                    listItems.add(category.title);
                    listItems.add(categoryRecipes);
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    120, // FAB と被らないよう余白を確保
                  ),
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                                item,
                                style: AppTextStyles.size16Bold(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (item is Recipe) {
                      // 単体のレシピ項目はここでは扱わない
                      return const SizedBox.shrink();
                    } else if (item is List<Recipe>) {
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: item.length,
                        itemBuilder: (context, i) =>
                            RecipeCard(recipe: item[i]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
              error: (error, stack) =>
                  Center(child: Text('エラーが発生しました: $error')),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add');
        },
        backgroundColor: AppColors.text,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'レシピを追加',
          style: AppTextStyles.size14Bold(color: Colors.white),
        ),
      ),
    );
  }
}
