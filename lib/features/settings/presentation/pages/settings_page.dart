import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/core/widgets/app_dialog.dart';
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
          const Padding(
            padding: EdgeInsets.all(16.0),
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
              style: AppTextStyles.size14Regular(color: AppColors.textSecondary),
            ),
          ),
          if (isAnonymous)
            _buildLinkAccountTile(context)
          else
            _buildLogoutTile(context, ref),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
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
                  style:
                      AppTextStyles.size14Regular(color: AppColors.textSecondary),
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
      leadingText(
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
      title: Text('ログアウト',
          style: AppTextStyles.size16Bold(color: AppColors.alert)ert),
      title: const Text('ログアウト', style: AppTextStyles.alert),
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
}
