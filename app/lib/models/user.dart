import 'package:flutter/foundation.dart';

class User {
  final int userId;
  final String username;
  final String? email;
  final bool isAdmin;

  User({
    required this.userId,
    required this.username,
    this.email,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      isAdmin: json['is_admin'] ?? false,
    );
  }
}
