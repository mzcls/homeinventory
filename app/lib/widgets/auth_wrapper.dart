import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/warehouse_list_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Schedule the auto-login check to run after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        switch (auth.status) {
          case AuthStatus.Authenticating:
          case AuthStatus.Uninitialized:
            // Show a loading spinner while checking authentication
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.Authenticated:
            // If authenticated, show the main app page
            return WarehouseListPage();
          case AuthStatus.Unauthenticated:
          default:
            // If not authenticated, show the login page
            return const LoginPage();
        }
      },
    );
  }
}
