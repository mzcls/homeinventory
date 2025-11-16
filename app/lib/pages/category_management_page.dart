import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/warehouse_provider.dart'; // To get current warehouse
import '../models/category.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if (authProvider.token != null && warehouseProvider.selectedWarehouse != null) {
      await categoryProvider.fetchCategories(authProvider.token!, warehouseProvider.selectedWarehouse!.id);
    }
  }

  Future<void> _addCategory() async {
    if (_categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分类名称不能为空')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if (authProvider.token != null && warehouseProvider.selectedWarehouse != null) {
      final success = await categoryProvider.createCategory(
        authProvider.token!,
        _categoryNameController.text,
        warehouseProvider.selectedWarehouse!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? '分类添加成功' : '分类添加失败')),
        );
        if (success) {
          _categoryNameController.clear();
        }
      }
    }
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('您确定要删除分类 "${category.name}" 吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      if (authProvider.token != null && warehouseProvider.selectedWarehouse != null) {
        final result = await categoryProvider.deleteCategory(
          authProvider.token!,
          category.categoryId!,
          warehouseProvider.selectedWarehouse!.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final warehouseProvider = Provider.of<WarehouseProvider>(context);

    if (warehouseProvider.selectedWarehouse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('分类管理')),
        body: const Center(child: Text('请先选择一个位置')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('分类管理 (${warehouseProvider.selectedWarehouse!.name})')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      labelText: '新分类名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('添加'),
                ),
              ],
            ),
          ),
          Expanded(
            child: categoryProvider.categories.isEmpty
                ? const Center(child: Text('没有找到分类。'))
                : ListView.builder(
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(category.name),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Optionally navigate to a category detail page or edit
                          },
                          onLongPress: () => _confirmDeleteCategory(category),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
