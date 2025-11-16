import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';

class MediaService {
  final Dio _dio = Dio();

  Future<Response> uploadMedia(String token, int itemId, XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      return await _dio.post(
        '${Config.apiBaseUrl}/media/upload/$itemId',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }

  Future<Response> deleteMedia(String token, int mediaId) async {
    try {
      return await _dio.delete(
        '${Config.apiBaseUrl}/media/$mediaId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioError catch (e) {
      return e.response!;
    }
  }
}