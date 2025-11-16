import 'user_warehouse.dart'; // Import UserRole enum

class Warehouse {
  final int id;
  final String name;
  final String? description;
  final int createdByUserId;
  final UserRole? role; // Add role field

  Warehouse({
    required this.id,
    required this.name,
    this.description,
    required this.createdByUserId,
    this.role,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['warehouse_id'],
      name: json['name'],
      description: json['description'],
      createdByUserId: json['created_by_user_id'],
      role: json['role'] != null
          ? UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == json['role'],
              orElse: () => UserRole.member,
            )
          : null,
    );
  }
}
