import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import DioError
import '../models/item.dart';
import '../services/item_service.dart';

class ItemSearchProvider with ChangeNotifier {
  final ItemService _itemService = ItemService();
  List<Item> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchItems(String token, String query) async {
    _isLoading = true;
    _errorMessage = null;
    _searchResults = []; // Clear previous results
    notifyListeners();

    if (query.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _itemService.searchAllItems(token, query);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _searchResults = (response.data['data'] as List)
            .map((itemJson) => Item.fromJson(itemJson))
            .toList();
      } else {
        debugPrint('Search API Error: ${response.statusCode} - ${response.data}');
        _errorMessage = response.data['message'] ?? '搜索失败';
      }
    } catch (e) {
      if (e is DioError) {
        debugPrint('DioError during search: ${e.response?.statusCode} - ${e.response?.data}');
        _errorMessage = e.response?.data['message'] ?? '发生网络错误';
      } else {
        debugPrint('Unknown error during search: $e');
        _errorMessage = '发生错误: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }
}
