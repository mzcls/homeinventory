import 'package:dio/dio.dart';
import '../config.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Response> register(String username, String? email, String password) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'password': password,
      };
      if (email != null) {
        data['email'] = email;
      }
      return await _dio.post(
        '${Config.apiBaseUrl}/auth/register',
        data: data,
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> login(String username, String password) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });
      print('Login Request URL: ${Config.apiBaseUrl}/auth/token');
      print('Login Request Data: ${formData.fields}');

      final response = await _dio.post(
        '${Config.apiBaseUrl}/auth/token',
        data: formData,
      );
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Data: ${response.data}');
      return response;
    } on DioError catch (e) {
      print('Login DioError: ${e.message}');
      if (e.response != null) {
        print('Login DioError Response Status: ${e.response!.statusCode}');
        print('Login DioError Response Data: ${e.response!.data}');
        return e.response!;
      }
      rethrow; // Re-throw if no response
    }
  }

  Future<Response> getUserInfo(String token) async {
    try {
      return await _dio.get(
        '${Config.apiBaseUrl}/auth/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> changePassword(String token, String newPassword) async {
    try {
      return await _dio.put(
        '${Config.apiBaseUrl}/auth/users/me/password',
        data: {'new_password': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }
}
