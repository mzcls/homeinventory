import 'package:dio/dio.dart';
import '../config.dart';

class CategoryService {
  final Dio _dio = Dio();

  Future<Response> getCategories(String token, int warehouseId) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/categories/warehouse/$warehouseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> createCategory(String token, String name, int warehouseId) async {
    try {
      return await _dio.post(
        '${Config.apiBaseUrl}/categories/',
        data: {
          'name': name,
          'warehouse_id': warehouseId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> deleteCategory(String token, int categoryId) async {
    try {
      return await _dio.delete(
        '${Config.apiBaseUrl}/categories/$categoryId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }
}
