import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import DioError for error handling
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  Category? _selectedCategory;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;

  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchCategories(String token, int warehouseId) async {
    try {
      final response = await _categoryService.getCategories(token, warehouseId);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _categories = data.map((json) => Category.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<bool> createCategory(String token, String name, int warehouseId) async {
    try {
      final response = await _categoryService.createCategory(token, name, warehouseId);
      if (response.statusCode == 201) {
        await fetchCategories(token, warehouseId); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating category: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteCategory(String token, int categoryId, int warehouseId) async {
    try {
      final response = await _categoryService.deleteCategory(token, categoryId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        await fetchCategories(token, warehouseId); // Refresh list
        return {'success': true, 'message': response.data['message'] ?? '分类删除成功'};
      }
      return {'success': false, 'message': response.data['message'] ?? '分类删除失败'};
    } on DioError catch (e) {
      debugPrint('DioError deleting category: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 409) {
        return {'success': false, 'message': e.response?.data['detail'] ?? '分类正在被物品使用，无法删除'};
      } else if (e.response?.data != null && e.response?.data['detail'] != null) {
        return {'success': false, 'message': e.response?.data['detail']};
      }
      return {'success': false, 'message': '网络错误或服务器无响应'};
    } catch (e) {
      debugPrint('Unknown error deleting category: $e');
      return {'success': false, 'message': '发生未知错误'};
    }
  }
}
