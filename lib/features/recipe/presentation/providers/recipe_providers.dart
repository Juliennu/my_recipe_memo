import 'dart:async';

import 'package:my_recipe_memo/features/auth/presentation/providers/auth_providers.dart';
import 'package:my_recipe_memo/features/recipe/data/recipe_repository.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_providers.g.dart';

@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  // ユーザーの変更を監視して再構築する
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  return ref.watch(recipeRepositoryProvider).watchRecipes();
}
