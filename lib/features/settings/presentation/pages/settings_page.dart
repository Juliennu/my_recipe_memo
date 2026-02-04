import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/core/widgets/app_cancel_button.dart';
import 'package:my_recipe_memo/core/widgets/app_dialog.dart';
import 'package:my_recipe_memo/core/widgets/app_primary_button.dart';
import 'package:my_recipe_memo/core/widgets/app_snackbar.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/login_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnonymous = ref.watch(isAnonymousUserProvider);
    final currentUid = ref.watch(currentUserIdProvider);
    final currentEmail = ref.watch(currentUserEmailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'アカウント情報',
              style: AppTextStyles.size14Bold(color: AppColors.textSecondary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              isAnonymous ? 'ゲストユーザー' : 'アカウント連携済み',
              style: AppTextStyles.size16Medium(),
            ),
            subtitle: Text(
              isAnonymous
                  ? 'ID: ${currentUid ?? "未ログイン"}'
                  : 'Email: ${currentEmail ?? "未設定"}',
              style: AppTextStyles.size14Regular(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (isAnonymous)
            _buildLinkAccountTile(context)
          else
            _buildLogoutTile(context, ref),
          _buildDeleteAccountTile(context, ref),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'アプリ情報',
              style: AppTextStyles.size14Bold(color: AppColors.textSecondary),
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final info = snapshot.data!;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('バージョン', style: AppTextStyles.size16Medium()),
                trailing: Text(
                  info.version,
                  style: AppTextStyles.size14Regular(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkAccountTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.link, color: AppColors.primary),
      title: Text(
        'アカウントを連携する',
        style: AppTextStyles.size16Bold(color: AppColors.primary),
      ),
      subtitle: Text(
        'データの引き継ぎや複数端末での利用が可能になります',
        style: AppTextStyles.size14Regular(color: AppColors.textSecondary),
      ),
      onTap: () {
        context.push('/settings/link');
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.alert),
      title: Text(
        'ログアウト',
        style: AppTextStyles.size16Bold(color: AppColors.alert),
      ),
      onTap: () async {
        await AppDialog.show(
          context,
          title: 'ログアウト',
          content: 'ログアウトしますか？',
          confirmText: 'ログアウト',
          isDestructive: true,
          onConfirm: () {
            ref.read(loginControllerProvider.notifier).signOut();
          },
        );
      },
    );
  }

  Widget _buildDeleteAccountTile(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(
        onPressed: () => _showDeleteConfirmSheet(context, ref),
        child: Text(
          'アカウント削除',
          style: AppTextStyles.size14Regular(color: AppColors.textDisabled),
        ),
      ),
    );
  }

  void _showDeleteConfirmSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'アカウント削除',
                style: AppTextStyles.size18Bold(color: AppColors.text),
              ),
              const SizedBox(height: 16),
              Text(
                'アカウントを削除すると、すべてのレシピデータが完全に消去されます。この操作は取り消せません。\n本当に削除しますか？',
                style: AppTextStyles.size14Regular(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32),
              AppPrimaryButton(
                text: '削除する',
                isDestructive: true,
                onPressed: () async {
                  // 非同期処理後にcontextがunmountされる可能性があるため、事前にmessengerを取得
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref
                        .read(loginControllerProvider.notifier)
                        .deleteAccount();
                    // 成功時、ルーターのリダイレクトによりログイン画面へ遷移する
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // シートを閉じる
                    }

                    String message = '削除に失敗しました';
                    if (e is FirebaseAuthException) {
                      if (e.code == 'requires-recent-login') {
                        message =
                            'セキュリティ保護のため、再ログインが必要です。\nログアウトして再度ログインした後、もう一度お試しください。';
                      } else {
                        message = '削除に失敗しました: ${e.message}';
                      }
                    } else {
                      message = '削除に失敗しました: $e';
                    }

                    // コンテキストが破棄されていてもスナックバーを表示できるようにする
                    AppSnackBar.show(
                      null,
                      message,
                      isError: true,
                      messenger: messenger,
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              AppCancelButton(
                text: 'キャンセル',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
