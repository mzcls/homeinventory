import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import DioError for error handling
import '../models/warehouse.dart';
import '../services/warehouse_service.dart';

class WarehouseProvider with ChangeNotifier {
  List<Warehouse> _warehouses = [];
  final WarehouseService _warehouseService = WarehouseService();
  Warehouse? _selectedWarehouse; // Add _selectedWarehouse

  List<Warehouse> get warehouses => _warehouses;
  Warehouse? get selectedWarehouse => _selectedWarehouse; // Add getter

  void selectWarehouse(Warehouse warehouse) { // Add setter
    _selectedWarehouse = warehouse;
    notifyListeners();
  }

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
      debugPrint('Error fetching warehouses: $e');
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
      debugPrint('Error creating warehouse: $e');
    }
  }

  Future<Map<String, dynamic>> deleteWarehouse(String token, int warehouseId) async {
    try {
      final response = await _warehouseService.deleteWarehouse(token, warehouseId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        await fetchWarehouses(token); // Refresh list
        return {'success': true, 'message': response.data['message'] ?? '位置删除成功'};
      }
      return {'success': false, 'message': response.data['message'] ?? '位置删除失败'};
    } on DioError catch (e) {
      debugPrint('DioError deleting warehouse: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 409) {
        return {'success': false, 'message': e.response?.data['detail'] ?? '位置正在被使用，无法删除'};
      } else if (e.response?.data != null && e.response?.data['detail'] != null) {
        return {'success': false, 'message': e.response?.data['detail']};
      }
      return {'success': false, 'message': '网络错误或服务器无响应'};
    } catch (e) {
      debugPrint('Unknown error deleting warehouse: $e');
      return {'success': false, 'message': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> inviteUserToWarehouse(String token, int warehouseId, String invitedUsername) async {
    try {
      final response = await _warehouseService.inviteUserToWarehouse(token, warehouseId, invitedUsername);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return {'success': true, 'message': response.data['message'] ?? '邀请成功'};
      }
      return {'success': false, 'message': response.data['message'] ?? '邀请失败'};
    } on DioError catch (e) {
      debugPrint('DioError inviting user to warehouse: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        return {'success': false, 'message': e.response?.data['detail']};
      }
      return {'success': false, 'message': '网络错误或服务器无响应'};
    } catch (e) {
      debugPrint('Unknown error inviting user to warehouse: $e');
      return {'success': false, 'message': '发生未知错误'};
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
      debugPrint('Error fetching user warehouses: $e');
      return [];
    }
  }
}
