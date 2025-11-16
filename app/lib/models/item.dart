import 'item_media.dart';
import 'category.dart'; // Import Category model

class Item {
  final int id;
  final String name;
  final Category? category;
  final String? location;
  final int quantity;
  final int warehouseId;
  final List<ItemMedia> media;
  final String? deletedAt;

  Item({
    required this.id,
    required this.name,
    this.category,
    this.location,
    required this.quantity,
    required this.warehouseId,
    this.media = const [],
    this.deletedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    var mediaList = json['media'] as List? ?? [];
    List<ItemMedia> media = mediaList.map((i) => ItemMedia.fromJson(i)).toList();

    return Item(
      id: json['item_id'],
      name: json['name'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      location: json['location'],
      quantity: json['quantity'],
      warehouseId: json['warehouse_id'],
      media: media,
      deletedAt: json['deleted_at'],
    );
  }
}
