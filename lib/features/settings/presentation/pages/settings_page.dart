import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(isAnonymous ? 'ゲストユーザー' : 'アカウント連携済み'),
            subtitle: Text(
              isAnonymous
                  ? 'ID: ${currentUid ?? "未ログイン"}'
                  : 'Email: ${currentEmail ?? "未設定"}',
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
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
                title: const Text('バージョン'),
                trailing: Text(
                  info.version,
                  style: const TextStyle(color: Colors.grey),
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
      title: const Text(
        'アカウントを連携する',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('データの引き継ぎや複数端末での利用が可能になります'),
      onTap: () {
        context.push('/settings/link');
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.alert),
      title: const Text('ログアウト', style: TextStyle(color: AppColors.alert)),
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
