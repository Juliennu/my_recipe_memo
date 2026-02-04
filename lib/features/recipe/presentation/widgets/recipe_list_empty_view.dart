import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';

class RecipeListEmptyView extends StatelessWidget {
  const RecipeListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 16),
          const Text(
            'レシピが見つかりません',
            style: TextStyle(color: AppColors.textDisabled),
          ),
          const SizedBox(height: 120), // 少し上に表示するために下部にスペースを追加
        ],
      ),
    );
  }
}
