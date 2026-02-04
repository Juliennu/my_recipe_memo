import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/add_recipe_page.dart';
import 'package:my_recipe_memo/features/recipe/presentation/pages/recipe_list_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RecipeListPage()),
      GoRoute(path: '/add', builder: (context, state) => const AddRecipePage()),
    ],
  );
}
