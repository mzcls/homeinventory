import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class AddItemPage extends StatefulWidget {
  final int warehouseId;

  const AddItemPage({Key? key, required this.warehouseId}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int? _selectedCategoryId;
  String? _location;
  int _quantity = 1;
  bool _isLoading = false;

  void _createItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      // Note: The createItem method in ItemProvider needs to be updated
      // to accept category_id instead of a category string.
      await Provider.of<ItemProvider>(context, listen: false)
          .createItem(token, _name, _selectedCategoryId, _location, _quantity, widget.warehouseId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('添加物品')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) => value!.isEmpty ? '请输入名称' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16), // Add spacing
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                value: _selectedCategoryId,
                items: categoryProvider.categories.map((Category category) {
                  return DropdownMenuItem<int>(
                    value: category.categoryId,
                    child: Text(
                      category.name,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                onSaved: (value) => _selectedCategoryId = value,
                validator: (value) => value == null ? '请选择分类' : null, // Category is now mandatory
              ),
              const SizedBox(height: 16), // Add spacing
              TextFormField(
                decoration: InputDecoration(
                  labelText: '位置',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) => value!.isEmpty ? '请输入位置' : null, // Location is now mandatory
                onSaved: (value) => _location = value,
              ),
              const SizedBox(height: 16), // Add spacing
              TextFormField(
                decoration: InputDecoration(
                  labelText: '数量',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                initialValue: '1',
                validator: (value) => int.tryParse(value!) == null ? '请输入有效的数字' : null,
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createItem,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Make button full width and taller
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                      ),
                      child: const Text('创建', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}