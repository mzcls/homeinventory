import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // Keep XFile import for video
import 'dart:typed_data'; // Import Uint8List
import '../config.dart';

class MediaService {
  final Dio _dio = Dio();

  Future<Response> uploadMedia(String token, int itemId, dynamic fileContent, String filename) async {
    try {
      MultipartFile multipartFile;
      if (fileContent is Uint8List) {
        multipartFile = MultipartFile.fromBytes(fileContent, filename: filename);
      } else if (fileContent is XFile) {
        multipartFile = await MultipartFile.fromFile(fileContent.path, filename: filename);
      } else {
        throw Exception("Unsupported file content type");
      }

      FormData formData = FormData.fromMap({
        "file": multipartFile,
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