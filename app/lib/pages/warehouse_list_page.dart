import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/warehouse_provider.dart';
import 'add_warehouse_page.dart';
import 'main_scaffold_page.dart'; // Import the new main page

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

  @override
  Widget build(BuildContext context) {
    final warehouseProvider = Provider.of<WarehouseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('位置列表'),
        actions: [
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MainScaffoldPage(warehouse: warehouse),
                        ),
                      );
                    },
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
