import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/login_controller.dart';

enum AuthTabType {
  linkAccount('アカウント連携 (新規)'),
  signIn('ログイン (既存)');

  const AuthTabType(this.label);
  final String label;

  static AuthTabType fromIndex(int index) {
    return AuthTabType.values.firstWhere(
      (e) => e.index == index,
      orElse: () => AuthTabType.linkAccount,
    );
  }
}

class LinkAccountPage extends ConsumerStatefulWidget {
  const LinkAccountPage({super.key});

  @override
  ConsumerState<LinkAccountPage> createState() => _LinkAccountPageState();
}

class _LinkAccountPageState extends ConsumerState<LinkAccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AuthTabType.values.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    // setStateを呼んでUIを更新（テキストの切り替えなど）
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final currentTab = AuthTabType.fromIndex(_tabController.index);
      final controller = ref.read(loginControllerProvider.notifier);

      try {
        switch (currentTab) {
          case AuthTabType.signIn:
            // ゲストユーザーの場合は、データ消失の警告を表示
            final isAnonymous = ref.read(isAnonymousUserProvider);
            if (isAnonymous) {
              final shouldLogin = await showModalBottomSheet<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(24.0),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '現在のデータが失われます',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '既存のアカウントにログインすると、現在のゲストユーザーとしてのデータは引き継がれません。\n本当にログインしますか？',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            fixedSize: const Size.fromWidth(double.maxFinite),
                          ),
                          child: const Text('確認してログインする'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('キャンセル'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );

              if (shouldLogin != true) return;
            }

            // 既存アカウントにログイン
            await controller.signIn(
              _emailController.text,
              _passwordController.text,
            );
            break;
          case AuthTabType.linkAccount:
            // アカウント連携（現在のデータを引き継ぐ）
            await controller.linkAccount(
              _emailController.text,
              _passwordController.text,
            );
            break;
        }

        if (mounted && !ref.read(loginControllerProvider).hasError) {
          final message = currentTab == AuthTabType.signIn
              ? 'ログインしました'
              : 'アカウントを連携しました';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context.pop(); // 設定画面に戻る
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.isLoading;
    final currentTab = AuthTabType.fromIndex(_tabController.index);

    ref.listen(loginControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${state.error}')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント設定'),
        bottom: TabBar(
          controller: _tabController,
          tabs: AuthTabType.values.map((e) => Tab(text: e.label)).toList(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 16),
            Text(
              currentTab == AuthTabType.linkAccount
                  ? '現在のデータを引き継いでアカウントを作成します。'
                  : '別のアカウントに切り替えます。（現在のゲストデータは失われます）',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!value.contains('@')) {
                  return '正しいメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                if (value.length < 6) {
                  return 'パスワードは6文字以上で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('実行する'),
            ),
          ],
        ),
      ),
    );
  }
}
