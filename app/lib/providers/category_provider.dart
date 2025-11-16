import 'package:flutter/material.dart';
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
      return false;
    }
  }

  Future<bool> deleteCategory(String token, int categoryId, int warehouseId) async {
    try {
      final response = await _categoryService.deleteCategory(token, categoryId);
      if (response.statusCode == 200) {
        await fetchCategories(token, warehouseId); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
