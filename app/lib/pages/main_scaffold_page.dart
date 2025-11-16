import 'package:flutter/material.dart';
import '../models/warehouse.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<String> _titles = ['当前物品', '历史物品', '设置'];

    return Scaffold(
      appBar: AppBar(
        title: Text('位置: ${widget.warehouse.name} - ${_titles[_selectedIndex]}'),
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
