import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD48B8B); // くすみピンク
  static const Color surface = Color(0xFFFFF7F5); // ほんのりピンクがかった白
  static const Color secondary = Color(0xFFBCAAA4);
  static const Color text = Color(0xFF5D4037);
  static const Color textSecondary = Color(0xFF8D6E63);
  static const Color white = Colors.white;

  // コンポーネント用
  static const Color inputBorder = Color(0xFFD48B8B);
  static const Color hintText = Color(0xFFBDBDBD); // Colors.grey[400]の近似
  static const Color alert = Color(0xFFE57373); // 注意・警告用（トーンを合わせた赤）
}
