import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_recipe_memo/features/auth/data/auth_repository.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) {
  return RecipeRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
}

class RecipeRepository {
  RecipeRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _recipesCollection =>
      _firestore.collection('recipes');

  Future<void> addRecipe(Recipe recipe) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    await _recipesCollection.add(
      recipe
          .copyWith(userId: user.uid, isFavorite: recipe.isFavorite)
          .toJsonForFirestore(),
    );
  }

  Future<void> deleteAllUserRecipes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final snapshot = await _recipesCollection
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<Recipe>> watchRecipes() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _recipesCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Recipe.fromJson(data).copyWith(id: doc.id);
          }).toList();
        });
  }

  Future<void> updateFavorite({
    required String recipeId,
    required bool isFavorite,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _recipesCollection.doc(recipeId).update({
      'isFavorite': isFavorite,
      'userId': user.uid,
    });
  }
}
