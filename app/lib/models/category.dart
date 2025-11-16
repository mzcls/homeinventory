class Category {
  final int categoryId;
  final String name;
  final int warehouseId;

  Category({
    required this.categoryId,
    required this.name,
    required this.warehouseId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      name: json['name'],
      warehouseId: json['warehouse_id'],
    );
  }
}
