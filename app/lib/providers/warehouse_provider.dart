import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../services/warehouse_service.dart';

class WarehouseProvider with ChangeNotifier {
  List<Warehouse> _warehouses = [];
  final WarehouseService _warehouseService = WarehouseService();

  List<Warehouse> get warehouses => _warehouses;

  Future<void> fetchWarehouses(String token) async {
    try {
      final response = await _warehouseService.getWarehouses(token);
      if (response.statusCode == 200) {
        final List<dynamic> warehouseData = response.data['data'];
        _warehouses = warehouseData.map((data) => Warehouse.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> createWarehouse(String token, String name, String? description) async {
    try {
      final response = await _warehouseService.createWarehouse(token, name, description);
      if (response.statusCode == 201) {
        await fetchWarehouses(token); // Refresh the list
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Warehouse>> fetchUserWarehouses(String token, int userId) async {
    try {
      final response = await _warehouseService.getUserWarehouses(token, userId);
      if (response.statusCode == 200) {
        final List<dynamic> warehouseData = response.data['data'];
        return warehouseData.map((data) => Warehouse.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      // Handle error
      print('Error fetching user warehouses: $e');
      return [];
    }
  }
}
