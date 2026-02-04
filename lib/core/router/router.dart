import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/auth/presentation/pages/link_account_page.dart';
import 'package:my_recipe_memo/features/auth/presentation/pages/login_page.dart';
import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/add_recipe_page.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/recipe_list_page.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/recipe_web_view_page.dart';
import 'package:my_recipe_memo/features/settings/presentation/pages/settings_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RecipeWebViewPage(
            url: extra['url'] as String,
            title: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const RecipeListPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddRecipePage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'link',
                builder: (context, state) => const LinkAccountPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isLoggingIn = state.uri.path == '/login';
      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
  );
}
