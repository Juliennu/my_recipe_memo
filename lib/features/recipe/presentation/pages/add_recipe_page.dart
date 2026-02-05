import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/widgets/app_primary_button.dart';
import 'package:my_recipe_memo/core/widgets/app_snackbar.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/recipe/data/recipe_repository.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';

class AddRecipePage extends ConsumerStatefulWidget {
  const AddRecipePage({super.key});

  @override
  ConsumerState<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends ConsumerState<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  RecipeCategory _selectedCategory = RecipeCategory.mainDish;
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) {
          throw Exception('ログインしていません');
        }

        final recipe = Recipe(
          userId: userId,
          title: _nameController.text,
          url: _urlController.text,
          category: _selectedCategory,
          createdAt: DateTime.now(),
        );

        await ref.read(recipeRepositoryProvider).addRecipe(recipe);

        if (mounted) {
          AppSnackBar.show(context, 'レシピを保存しました');
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.show(
            context,
            '保存に失敗しました: $e',
            isError: true,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レシピ登録')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'レシピのURL',
                hintText: 'https://example.com/recipe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'URLを入力してください';
                }
                // 簡単なURL形式チェック
                if (!Uri.parse(value).isAbsolute) {
                  return '有効なURLを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'レシピ名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'レシピ名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownMenu<RecipeCategory>(
                    width: constraints.maxWidth,
                    initialSelection: _selectedCategory,
                    label: const Text('カテゴリ'),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(AppColors.white),
                    ),
                    leadingIcon: const Icon(Icons.category),
                    onSelected: (v) => setState(() => _selectedCategory = v!),
                    dropdownMenuEntries: RecipeCategory.values.map((c) {
                      return DropdownMenuEntry(value: c, label: c.title);
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              text: '保存する',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
