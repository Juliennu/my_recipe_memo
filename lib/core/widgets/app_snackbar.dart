import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext? context,
    String message, {
    bool isError = false,
    ScaffoldMessengerState? messenger,
  }) {
    final scaffoldMessenger =
        messenger ?? (context != null ? ScaffoldMessenger.of(context) : null);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isError ? AppColors.alert : AppColors.text,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    );
  }
}
