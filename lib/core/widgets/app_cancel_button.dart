import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';

class AppCancelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppCancelButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
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
