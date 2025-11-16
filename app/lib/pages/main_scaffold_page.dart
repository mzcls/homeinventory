import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../providers/warehouse_provider.dart'; // Import WarehouseProvider
import 'item_list_page.dart';
import 'deleted_items_page.dart';
import 'settings_page.dart';

class MainScaffoldPage extends StatefulWidget {
  final Warehouse warehouse;

  const MainScaffoldPage({Key? key, required this.warehouse}) : super(key: key);

  @override
  _MainScaffoldPageState createState() => _MainScaffoldPageState();
}

class _MainScaffoldPageState extends State<MainScaffoldPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      ItemListPage(warehouse: widget.warehouse),
      DeletedItemsPage(warehouse: widget.warehouse),
      const SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showShareWarehouseDialog() async {
    final TextEditingController usernameController = TextEditingController(); // Changed to usernameController
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('分享位置'),
          content: TextField(
            controller: usernameController, // Changed to usernameController
            decoration: const InputDecoration(hintText: "被邀请用户的用户名"), // Changed hintText
            keyboardType: TextInputType.text, // Changed keyboardType
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('邀请'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _inviteUserToWarehouse(usernameController.text); // Changed to usernameController.text
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _inviteUserToWarehouse(String username) async { // Changed parameter name
    if (username.isEmpty) { // Changed validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名不能为空')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);

    if (authProvider.token != null) {
      final result = await warehouseProvider.inviteUserToWarehouse(
        authProvider.token!,
        widget.warehouse.id,
        username, // Changed to username
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _titles = ['当前物品', '历史物品', '设置'];

    return Scaffold(
      appBar: AppBar(
        title: Text('位置: ${widget.warehouse.name} - ${_titles[_selectedIndex]}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareWarehouseDialog,
            tooltip: '分享位置',
          ),
        ],
      ),
      body: IndexedStack( // Use IndexedStack to keep state of pages
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '当前物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '历史物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
