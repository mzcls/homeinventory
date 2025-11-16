import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_panel_page.dart'; // Import the new admin panel page
import 'category_management_page.dart'; // Import CategoryManagementPage
import 'change_password_page.dart'; // Import ChangePasswordPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ListView(
          children: [
            if (authProvider.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('后台管理'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('分类管理'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CategoryManagementPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('修改密码'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              },
            ),
            // Other settings options can go here
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: () {
                authProvider.logout();
              },
            ),
          ],
        );
      },
    );
  }
}
