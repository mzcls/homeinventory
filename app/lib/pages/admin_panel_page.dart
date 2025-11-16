import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/user.dart';
import '../models/warehouse.dart';
import '../models/user_warehouse.dart'; // For UserRole enum
import '../providers/warehouse_provider.dart'; // Import WarehouseProvider

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int? _selectedUserId; // Changed to int?
  int? _selectedWarehouseId; // Changed to int?
  UserRole _selectedRole = UserRole.member;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (authProvider.token != null) {
      await adminProvider.fetchAllUsers(authProvider.token!);
      await adminProvider.fetchAllWarehouses(authProvider.token!);
    }
  }

  Future<void> _assignWarehouse() async {
    if (_selectedUserId == null || _selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择用户和位置')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final success = await adminProvider.assignWarehouseToUser(
      authProvider.token!,
      _selectedUserId!,
      _selectedWarehouseId!,
      _selectedRole.name,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '分配成功' : '分配失败')),
      );
      if (success) {
        _fetchAdminData(); // Refresh data
      }
    }
  }

  Future<void> _removeAssignment(int userId, int warehouseId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final success = await adminProvider.removeWarehouseAssignment(
      authProvider.token!,
      userId,
      warehouseId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '移除成功' : '移除失败')),
      );
      if (success) {
        _fetchAdminData(); // Refresh data
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置管理'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('分配位置权限', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>( // Changed to int
                  decoration: InputDecoration(
                    labelText: '选择用户',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: _selectedUserId, // Changed to _selectedUserId
                  items: adminProvider.allUsers.map((user) {
                    return DropdownMenuItem<int>( // Changed to int
                      value: user.userId, // Use userId as value
                      child: Text(user.username, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (int? newValue) { // Changed to int?
                    setState(() {
                      _selectedUserId = newValue; // Set _selectedUserId
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>( // Changed to int
                  decoration: InputDecoration(
                    labelText: '选择位置',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: _selectedWarehouseId, // Changed to _selectedWarehouseId
                  items: adminProvider.allWarehouses.map((warehouse) {
                    return DropdownMenuItem<int>( // Changed to int
                      value: warehouse.id, // Use warehouse.id as value
                      child: Text(warehouse.name, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (int? newValue) { // Changed to int?
                    setState(() {
                      _selectedWarehouseId = newValue; // Set _selectedWarehouseId
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<UserRole>(
                  decoration: InputDecoration(
                    labelText: '选择角色',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: _selectedRole,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(role.name, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _selectedRole = newValue ?? UserRole.member;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _assignWarehouse,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button full width and taller
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: const Text('分配/更新权限', style: TextStyle(fontSize: 18)),
                ),
                const Divider(height: 40),
                const Text('所有用户及其位置权限', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: adminProvider.allUsers.length,
                    itemBuilder: (context, userIndex) {
                      final user = adminProvider.allUsers[userIndex];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('用户: ${user.username} ${user.isAdmin ? '(管理员)' : ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              FutureBuilder<List<Warehouse>>(
                                future: Provider.of<WarehouseProvider>(context, listen: false).fetchUserWarehouses(
                                  Provider.of<AuthProvider>(context, listen: false).token!,
                                  user.userId,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('加载位置失败: ${snapshot.error}');
                                  }
                                  final userWarehouses = snapshot.data ?? [];
                                  if (userWarehouses.isEmpty) {
                                    return const Text('没有分配的位置');
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: userWarehouses.map((wh) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('- ${wh.name} (${wh.role?.name ?? 'member'})'),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            onPressed: () => _removeAssignment(user.userId, wh.id),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
