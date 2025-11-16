import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import DioError for error handling
import '../models/user.dart';
import '../models/warehouse.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  List<User> _allUsers = [];
  List<Warehouse> _allWarehouses = [];

  List<User> get allUsers => _allUsers;
  List<Warehouse> get allWarehouses => _allWarehouses;

  Future<void> fetchAllUsers(String token) async {
    _allUsers = await _adminService.getAllUsers(token);
    debugPrint('AdminProvider: Fetched ${_allUsers.length} users.');
    notifyListeners();
  }

  Future<void> fetchAllWarehouses(String token) async {
    _allWarehouses = await _adminService.getAllWarehouses(token);
    debugPrint('AdminProvider: Fetched ${_allWarehouses.length} warehouses.');
    notifyListeners();
  }

  Future<bool> assignWarehouseToUser(String token, int userId, int warehouseId, String role) async {
    final success = await _adminService.assignWarehouseToUser(token, userId, warehouseId, role);
    if (success) {
      // Optionally refresh data if needed
      await fetchAllUsers(token); // Refresh users to show updated assignments
      await fetchAllWarehouses(token); // Refresh warehouses if their user assignments are part of their data
    }
    return success;
  }

  Future<bool> removeWarehouseAssignment(String token, int userId, int warehouseId) async {
    final success = await _adminService.removeWarehouseAssignment(token, userId, warehouseId);
    if (success) {
      // Optionally refresh data if needed
      await fetchAllUsers(token); // Refresh users to show updated assignments
      await fetchAllWarehouses(token); // Refresh warehouses if their user assignments are part of their data
    }
    return success;
  }

  Future<Map<String, dynamic>> resetUserPassword(String token, int userId) async {
    // AdminService.resetUserPassword already returns a structured map with 'success' and 'message'
    // and handles DioError internally.
    return await _adminService.resetUserPassword(token, userId);
  }
}
