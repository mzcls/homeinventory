import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import 'item_detail_page.dart'; // Import the detail page

class DeletedItemsPage extends StatefulWidget {
  final Warehouse warehouse;

  const DeletedItemsPage({Key? key, required this.warehouse}) : super(key: key);

  @override
  _DeletedItemsPageState createState() => _DeletedItemsPageState();
}

class _DeletedItemsPageState extends State<DeletedItemsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ItemProvider>(context, listen: false)
        .fetchDeletedItems(authProvider.token!, widget.warehouse.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: '搜索已删除物品',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: Consumer<ItemProvider>(
            builder: (context, itemProvider, child) {
              final filteredItems = itemProvider.deletedItems.where((item) {
                return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredItems.isEmpty) {
                return const Center(child: Text('没有找到已删除的物品。'));
              }
              return ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item.name, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                    subtitle: Text('删除于: ${item.deletedAt}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(itemId: item.id, includeDeleted: true),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
