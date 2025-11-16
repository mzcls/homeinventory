import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart'; // Import CategoryProvider
import '../models/category.dart'; // Import Category model

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  int? _selectedCategoryId; // Changed to int?
  late String? _location;
  late int _quantity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.item.name;
    _selectedCategoryId = widget.item.category?.categoryId; // Initialize with categoryId
    _location = widget.item.location;
    _quantity = widget.item.quantity;
  }

  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      await Provider.of<ItemProvider>(context, listen: false)
          .updateItem(token, widget.item.id, _name, _selectedCategoryId, _location, _quantity, widget.item.warehouseId);
      Navigator.of(context).pop();
    }
  }

  void _deleteItem() async {
    setState(() {
      _isLoading = true;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    await Provider.of<ItemProvider>(context, listen: false)
        .deleteItem(token, widget.item.id, widget.item.warehouseId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑物品'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
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
                initialValue: _location,
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
                initialValue: _quantity.toString(),
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
                validator: (value) => int.tryParse(value!) == null ? '请输入有效的数字' : null,
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateItem,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Make button full width and taller
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                      ),
                      child: const Text('更新', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}