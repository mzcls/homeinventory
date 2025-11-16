import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/warehouse.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import 'add_item_page.dart';
import 'item_detail_page.dart';
import 'deleted_items_page.dart'; // Import the new page

class ItemListPage extends StatefulWidget {
  final Warehouse warehouse;

  const ItemListPage({Key? key, required this.warehouse}) : super(key: key);

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token!;
    Provider.of<ItemProvider>(context, listen: false).fetchItems(token, widget.warehouse.id);
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories(token, widget.warehouse.id);
  }

  Future<void> _showAddCategoryDialog() async {
    final categoryNameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加新分类'),
          content: TextField(
            controller: categoryNameController,
            decoration: const InputDecoration(hintText: "分类名称"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('添加'),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                final success = await categoryProvider.createCategory(
                  authProvider.token!,
                  categoryNameController.text,
                  widget.warehouse.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? '分类添加成功' : '分类添加失败')),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChips(CategoryProvider categoryProvider) {
    List<Widget> chips = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
          label: const Text('全部'),
          selected: categoryProvider.selectedCategory == null,
          onSelected: (selected) {
            if (selected) {
              categoryProvider.selectCategory(null);
            }
          },
          selectedColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(color: categoryProvider.selectedCategory == null ? Colors.white : Colors.black),
        ),
      ),
    ];

    for (var category in categoryProvider.categories) {
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(category.name),
            selected: categoryProvider.selectedCategory?.categoryId == category.categoryId,
            onSelected: (selected) {
              if (selected) {
                categoryProvider.selectCategory(category);
              }
            },
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(color: categoryProvider.selectedCategory?.categoryId == category.categoryId ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ActionChip(
          label: const Icon(Icons.add, size: 18, color: Colors.black),
          onPressed: _showAddCategoryDialog,
          tooltip: '添加新分类',
          backgroundColor: Colors.grey[200],
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final filteredItems = itemProvider.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = categoryProvider.selectedCategory == null ||
          item.category?.categoryId == categoryProvider.selectedCategory?.categoryId;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: '搜索物品',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: _buildCategoryChips(categoryProvider),
          ),
          const Divider(height: 1, thickness: 1), // Enhanced divider
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('没有找到物品。'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item.category?.name ?? '未分类',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            '数量: ${item.quantity}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ItemDetailPage(itemId: item.id),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('确认删除'),
                                content: Text('您确定要删除物品 "${item.name}" 吗？'),
                                actions: [
                                  TextButton(
                                    child: const Text('取消'),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final result = await itemProvider.deleteItem(
                                        authProvider.token!,
                                        item.id,
                                        widget.warehouse.id,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(result['message'])),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddItemPage(warehouseId: widget.warehouse.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}