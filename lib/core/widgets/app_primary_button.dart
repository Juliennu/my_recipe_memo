import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? AppColors.alert : AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.size14Bold(color: AppColors.white),
              ),
      ),
    );
  }
}
