import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/warehouse.dart'; // Import Warehouse model
import 'add_warehouse_page.dart';
import 'main_scaffold_page.dart'; // Import the new main page
import 'item_search_page.dart'; // Import ItemSearchPage

class WarehouseListPage extends StatefulWidget {
  const WarehouseListPage({Key? key}) : super(key: key);

  @override
  _WarehouseListPageState createState() => _WarehouseListPageState();
}

class _WarehouseListPageState extends State<WarehouseListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch warehouses when the page loads
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<WarehouseProvider>(context, listen: false)
        .fetchWarehouses(authProvider.token!);
  }

  Future<void> _confirmDeleteWarehouse(Warehouse warehouse) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('您确定要删除位置 "${warehouse.name}" 吗？'),
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

      if (authProvider.token != null) {
        final result = await warehouseProvider.deleteWarehouse(
          authProvider.token!,
          warehouse.id,
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
  Widget build(BuildContext context) {
    final warehouseProvider = Provider.of<WarehouseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('位置列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // Search icon
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ItemSearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: warehouseProvider.warehouses.isEmpty
          ? const Center(child: Text('没有找到位置。'))
          : ListView.builder(
              itemCount: warehouseProvider.warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouseProvider.warehouses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      warehouse.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      warehouse.description ?? '无描述',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      warehouseProvider.selectWarehouse(warehouse); // Set selected warehouse
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MainScaffoldPage(warehouse: warehouse),
                        ),
                      );
                    },
                    onLongPress: () => _confirmDeleteWarehouse(warehouse), // Long press for delete
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddWarehousePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
