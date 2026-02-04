import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';

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
          Text(
            'レシピが見つかりません',
            style: AppTextStyles.size14Regular(color: AppColors.textDisabled),
          ),
          const SizedBox(height: 120), // 少し上に表示するために下部にスペースを追加
        ],
      ),
    );
  }
}
