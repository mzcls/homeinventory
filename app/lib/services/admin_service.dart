import 'package:dio/dio.dart';
import '../config.dart';
import '../models/user.dart';
import '../models/warehouse.dart';
import '../models/user_warehouse.dart'; // Import UserWarehouse model

class AdminService {
  final Dio _dio = Dio();

  Future<List<User>> getAllUsers(String token) async {
    try {
      final response = await _dio.get(
        '${Config.apiBaseUrl}/admin/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      return [];
    } on DioError catch (e) {
      print('Error fetching all users: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  Future<List<Warehouse>> getAllWarehouses(String token) async {
    try {
      final response = await _dio.get(
        '${Config.apiBaseUrl}/admin/warehouses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return (response.data['data'] as List)
            .map((json) => Warehouse.fromJson(json))
            .toList();
      }
      return [];
    } on DioError catch (e) {
      print('Error fetching all warehouses: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  Future<bool> assignWarehouseToUser(String token, int userId, int warehouseId, String role) async {
    try {
      final response = await _dio.post(
        '${Config.apiBaseUrl}/admin/assign_warehouse',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'user_id': userId,
          'warehouse_id': warehouseId,
          'role': role,
        },
      );
      return response.statusCode == 200 && response.data['status'] == 'success';
    } on DioError catch (e) {
      print('Error assigning warehouse to user: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  Future<bool> removeWarehouseAssignment(String token, int userId, int warehouseId) async {
    try {
      final response = await _dio.delete(
        '${Config.apiBaseUrl}/admin/remove_warehouse_assignment',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {
          'user_id': userId,
          'warehouse_id': warehouseId,
        },
      );
      return response.statusCode == 200 && response.data['status'] == 'success';
    } on DioError catch (e) {
      print('Error removing warehouse assignment: ${e.response?.data ?? e.message}');
      return false;
    }
  }
}
