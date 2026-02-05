enum RecipeCategory {
  mainDish,
  sideDish,
  soup,
  salad,
  dessert,
  snack,
  other;

  String get title {
    return switch (this) {
      .mainDish => '主食',
      .sideDish => 'おかず',
      .soup => '汁物',
      .salad => 'サラダ',
      .dessert => 'デザート',
      .snack => 'つまみ',
      .other => 'その他',
    };
  }
}
