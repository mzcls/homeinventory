import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/warehouse_provider.dart';
import 'providers/item_provider.dart';
import 'providers/media_provider.dart';
import 'providers/category_provider.dart'; // Import CategoryProvider
import 'providers/admin_provider.dart'; // Import AdminProvider
import 'providers/item_search_provider.dart'; // Import ItemSearchProvider
import 'widgets/auth_wrapper.dart'; // Import the new wrapper

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WarehouseProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // Add CategoryProvider
        ChangeNotifierProvider(create: (_) => AdminProvider()), // Add AdminProvider
        ChangeNotifierProvider(create: (_) => ItemSearchProvider()), // Add ItemSearchProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家庭物品',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Use the AuthWrapper as the home
    );
  }
}