class Category {
   int categoryId;
   String categoryName;

  Category(this.categoryName);

  Category.withId(this.categoryId, this.categoryName);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['categoryId'] = this.categoryId;
    map['categoryName'] = this.categoryName;
    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.categoryName = map['categoryName'];
    this.categoryId = map['categoryId'];
  }

  @override
  String toString() {
    return 'Category{categoryId: $categoryId, categoryName: $categoryName}';
  }
}
