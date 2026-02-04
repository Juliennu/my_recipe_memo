import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle size28SemiBold({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle size18Bold({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: letterSpacing ?? 1.2,
    height: height,
    color: color,
  );

  static TextStyle size16Bold({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle size16Medium({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle size14Bold({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle size14Regular({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle size12Regular({
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
