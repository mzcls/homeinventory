import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
// import 'warehouse_list_page.dart'; // No longer directly navigate here

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true; // Default to true as per requirement

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedUsername = await authProvider.getSavedUsername();
    final savedPassword = await authProvider.getSavedPassword();

    if (savedUsername != null) {
      _usernameController.text = savedUsername;
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
    // If either is null, assume rememberMe was false or not set, so default to false
    // Or, if we want to default to true, we can keep it true.
    // For now, let's keep it true as per the request "默认记住"
    // _rememberMe = savedUsername != null && savedPassword != null;
    setState(() {}); // Update UI with pre-filled values
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        if (success) {
          // AuthWrapper will handle navigation after login status changes
          // No need to navigate here directly
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录失败，请检查用户名或密码')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: (value) => value!.isEmpty ? '请输入用户名' : null,
                // onSaved: (value) => _username = value!, // No longer needed with controller
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? '请输入密码' : null,
                // onSaved: (value) => _password = value!, // No longer needed with controller
              ),
              CheckboxListTile(
                title: const Text('记住账号密码'),
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Make button full width and taller
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                      ),
                      child: const Text('登录', style: TextStyle(fontSize: 18)),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor, // Use primary color for text
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('没有账号？注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
