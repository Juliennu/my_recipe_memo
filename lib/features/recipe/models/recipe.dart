import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}

class RecipeCategoryConverter implements JsonConverter<RecipeCategory, String> {
  const RecipeCategoryConverter();

  @override
  RecipeCategory fromJson(String json) {
    return RecipeCategory.values.firstWhere(
      (e) => e.title == json,
      orElse: () => RecipeCategory.other,
    );
  }

  @override
  String toJson(RecipeCategory object) {
    return object.title;
  }
}

@freezed
abstract class Recipe with _$Recipe {
  const Recipe._();

  const factory Recipe({
    String? id,
    required String userId,
    required String title,
    required String url,
    @RecipeCategoryConverter() required RecipeCategory category,
    @TimestampConverter() required DateTime createdAt,
    @Default(false) bool isFavorite,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJsonForFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
