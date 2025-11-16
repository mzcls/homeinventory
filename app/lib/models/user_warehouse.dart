import 'package:flutter/foundation.dart';

enum UserRole {
  owner,
  member,
}

class UserWarehouse {
  final int id;
  final int userId;
  final int warehouseId;
  final UserRole role;

  UserWarehouse({
    required this.id,
    required this.userId,
    required this.warehouseId,
    required this.role,
  });

  factory UserWarehouse.fromJson(Map<String, dynamic> json) {
    return UserWarehouse(
      id: json['id'],
      userId: json['user_id'],
      warehouseId: json['warehouse_id'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.member,
      ),
    );
  }
}
