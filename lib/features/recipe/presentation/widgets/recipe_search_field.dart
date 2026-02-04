import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';

class RecipeSearchField extends ConsumerWidget {
  const RecipeSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'レシピを検索',
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
}
