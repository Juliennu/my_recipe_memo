import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/widgets/app_cancel_button.dart';
import 'package:my_recipe_memo/core/widgets/app_primary_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final Color? confirmTextColor;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'キャンセル',
    required this.confirmText,
    required this.onConfirm,
    this.confirmTextColor,
    this.isDestructive = false,
  });

  /// 汎用ダイアログを表示する
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'キャンセル',
    required String confirmText,
    Color? confirmTextColor,
    bool isDestructive = false,
    VoidCallback? onConfirm,
  }) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmTextColor: confirmTextColor,
        isDestructive: isDestructive,
        onConfirm: () {
          onConfirm?.call();
          Navigator.pop(context, true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent() {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCancelButton(
            text: cancelText,
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppPrimaryButton(
            text: confirmText,
            onPressed: onConfirm,
            isDestructive: isDestructive,
          ),
        ),
      ],
    );
  }
}
