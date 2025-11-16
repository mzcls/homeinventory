import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/item_search_provider.dart';
import '../models/item.dart';
import 'item_detail_page.dart';

class ItemSearchPage extends StatefulWidget {
  const ItemSearchPage({Key? key}) : super(key: key);

  @override
  _ItemSearchPageState createState() => _ItemSearchPageState();
}

class _ItemSearchPageState extends State<ItemSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text != _currentSearchQuery) {
      setState(() {
        _currentSearchQuery = _searchController.text;
      });
      _performSearch(_currentSearchQuery);
    }
  }

  void _performSearch(String query) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final itemSearchProvider = Provider.of<ItemSearchProvider>(context, listen: false);
    if (authProvider.token != null) {
      itemSearchProvider.searchItems(authProvider.token!, query);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // Clear search results when leaving the page
    Provider.of<ItemSearchProvider>(context, listen: false).clearSearchResults();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索所有物品...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<ItemSearchProvider>(context, listen: false).clearSearchResults();
                    },
                  )
                : null,
          ),
          autofocus: true,
          onSubmitted: (value) => _performSearch(value),
        ),
      ),
      body: Consumer<ItemSearchProvider>(
        builder: (context, itemSearchProvider, child) {
          if (itemSearchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (itemSearchProvider.errorMessage != null) {
            return Center(child: Text('错误: ${itemSearchProvider.errorMessage}'));
          } else if (itemSearchProvider.searchResults.isEmpty && _currentSearchQuery.isNotEmpty) {
            return const Center(child: Text('没有找到相关物品。'));
          } else if (itemSearchProvider.searchResults.isEmpty && _currentSearchQuery.isEmpty) {
            return const Center(child: Text('请输入搜索关键词。'));
          } else {
            return ListView.builder(
              itemCount: itemSearchProvider.searchResults.length,
              itemBuilder: (context, index) {
                final item = itemSearchProvider.searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('位置: ${item.location ?? 'N/A'} | 数量: ${item.quantity}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(itemId: item.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
