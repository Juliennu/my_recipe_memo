import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/login_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnonymous = ref.watch(isAnonymousUserProvider);
    final currentUid = ref.watch(currentUserIdProvider);

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
            subtitle: Text('ID: ${currentUid ?? "未ログイン"}'),
          ),
          if (isAnonymous)
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text(
                'アカウントを連携する',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('データの引き継ぎや複数端末での利用が可能になります'),
              onTap: () {
                context.push('/settings/link');
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ログアウト'),
                    content: const Text('ログアウトしますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('ログアウト'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  await ref.read(loginControllerProvider.notifier).signOut();
                  // Routerのリダイレクトによりログイン画面へ遷移するため、ここでは何もしない
                }
              },
            ),
        ],
      ),
    );
  }
}
