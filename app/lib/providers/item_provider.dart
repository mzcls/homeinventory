import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  List<Item> _deletedItems = []; // New list for deleted items
  Item? _selectedItem;
  final ItemService _itemService = ItemService();

  List<Item> get items => _items;
  List<Item> get deletedItems => _deletedItems; // Getter for deleted items
  Item? get selectedItem => _selectedItem;

  Future<void> fetchItems(String token, int warehouseId) async {
    try {
      final response = await _itemService.getItems(token, warehouseId);
      if (response.statusCode == 200) {
        final List<dynamic> itemData = response.data['data'];
        _items = itemData.map((data) => Item.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchDeletedItems(String token, int warehouseId) async {
    try {
      final response = await _itemService.getDeletedItems(token, warehouseId);
      if (response.statusCode == 200) {
        final List<dynamic> itemData = response.data['data'];
        _deletedItems = itemData.map((data) => Item.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchItem(String token, int itemId, {bool includeDeleted = false}) async {
    try {
      final response = await _itemService.getItem(token, itemId, includeDeleted: includeDeleted);
      if (response.statusCode == 200) {
        _selectedItem = Item.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> createItem(String token, String name, int? categoryId, String? location, int quantity, int warehouseId) async {
    try {
      final response = await _itemService.createItem(token, name, categoryId, location, quantity, warehouseId);
      if (response.statusCode == 201) {
        await fetchItems(token, warehouseId); // Refresh the list
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateItem(String token, int itemId, String name, int? categoryId, String? location, int quantity, int warehouseId) async {
    try {
      final response = await _itemService.updateItem(token, itemId, name, categoryId, location, quantity);
      if (response.statusCode == 200) {
        // Also refresh the selected item to update the detail page
        await fetchItem(token, itemId);
        // Refresh the list for the item list page
        await fetchItems(token, warehouseId); 
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<Map<String, dynamic>> deleteItem(String token, int itemId, int warehouseId) async {
    try {
      final result = await _itemService.deleteItem(token, itemId);
      if (result['success']) {
        await fetchItems(token, warehouseId); // Refresh the list
        await fetchDeletedItems(token, warehouseId); // Refresh deleted items list
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': '删除物品时发生错误'};
    }
  }

  Future<bool> restoreItem(String token, int itemId, int warehouseId) async {
    try {
      final response = await _itemService.restoreItem(token, itemId);
      if (response.statusCode == 200) {
        await fetchItems(token, warehouseId); // Refresh the list
        await fetchDeletedItems(token, warehouseId); // Refresh deleted items list
        return true;
      }
      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }
}