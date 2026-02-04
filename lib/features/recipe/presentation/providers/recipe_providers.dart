import 'dart:async';

import 'package:my_recipe_memo/features/recipe/data/recipe_repository.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_providers.g.dart';

@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  return ref.watch(recipeRepositoryProvider).watchRecipes();
}
