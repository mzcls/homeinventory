import 'package:dio/dio.dart';
import '../config.dart';

class WarehouseService {
  final Dio _dio = Dio();

  Future<Response> getWarehouses(String token) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/warehouses/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> createWarehouse(String token, String name, String? description) async {
    try {
      return await _dio.post(
        '${Config.apiBaseUrl}/warehouses/',
        data: {
          'name': name,
          'description': description,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> deleteWarehouse(String token, int warehouseId) async {
    try {
      return await _dio.delete(
        '${Config.apiBaseUrl}/warehouses/$warehouseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> inviteUserToWarehouse(String token, int warehouseId, String invitedUsername) async {
    try {
      return await _dio.post(
        '${Config.apiBaseUrl}/warehouses/$warehouseId/invite',
        queryParameters: {'invited_username': invitedUsername}, // Send as query parameter as per backend route
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> getUserWarehouses(String token, int userId) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/warehouses/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }
}
