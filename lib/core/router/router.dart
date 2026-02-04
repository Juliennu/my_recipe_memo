import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/add_recipe_page.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/recipe_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RecipeListPage(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddRecipePage(),
      ),
    ],
  );
});
