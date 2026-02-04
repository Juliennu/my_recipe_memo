import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_recipe_memo/features/recipe/domain/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) {
  return RecipeRepository(ref.watch(firebaseFirestoreProvider));
}

class RecipeRepository {
  RecipeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _recipesCollection =>
      _firestore.collection('recipes');

  Future<void> addRecipe(Recipe recipe) async {
    await _recipesCollection.add(recipe.toJsonForFirestore());
  }

  Stream<List<Recipe>> watchRecipes() {
    return _recipesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Recipe.fromJson(data).copyWith(id: doc.id);
          }).toList();
        });
  }
}
