import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';

class AppCancelButton extends StatelessWidget {
  const AppCancelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
  });

  final String text;
  final VoidCallback onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.size14Bold(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
