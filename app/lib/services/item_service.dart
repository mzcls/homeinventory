import 'package:dio/dio.dart';
import '../config.dart';

class ItemService {
  final Dio _dio = Dio();

  Future<Response> getItems(String token, int warehouseId) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/items/warehouse/$warehouseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> getItem(String token, int itemId, {bool includeDeleted = false}) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/items/$itemId',
        queryParameters: {'include_deleted': includeDeleted}, // Add query parameter
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> createItem(String token, String name, int? categoryId, String? location, int quantity, int warehouseId) async {
    try {
      return await _dio.post(
        '${Config.apiBaseUrl}/items/',
        data: {
          'name': name,
          'category_id': categoryId,
          'location': location,
          'quantity': quantity,
          'warehouse_id': warehouseId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> updateItem(String token, int itemId, String name, int? categoryId, String? location, int quantity) async {
    try {
      return await _dio.put(
        '${Config.apiBaseUrl}/items/$itemId',
        data: {
          'name': name,
          'category_id': categoryId,
          'location': location,
          'quantity': quantity,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Map<String, dynamic>> deleteItem(String token, int itemId) async {
    try {
      final response = await _dio.delete(
        '${Config.apiBaseUrl}/items/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return {'success': true, 'message': response.data['message'] ?? '删除成功'};
      }
      return {'success': false, 'message': response.data['message'] ?? '删除失败'};
    } on DioError catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? '删除失败'};
    }
  }

  Future<Response> getDeletedItems(String token, int warehouseId) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/items/warehouse/$warehouseId/deleted',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> restoreItem(String token, int itemId) async {
    try {
      return await _dio.post(
        '${Config.apiBaseUrl}/items/restore/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }
}