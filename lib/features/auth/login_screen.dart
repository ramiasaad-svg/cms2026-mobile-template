import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/config/app_config.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth;
  final BrandingConfig branding;
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.auth, required this.branding, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final success = await widget.auth.login(_userController.text, _passController.text);
    setState(() => _loading = false);

    if (success) {
      AnalyticsService.logLogin();
      widget.onLoginSuccess();
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [widget.branding.primary, widget.branding.secondary]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outlined, size: 48, color: widget.branding.primary),
                  const SizedBox(height: 16),
                  const Text('Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: _userController,
                    decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _passController, obscureText: _obscure,
                    decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                      border: const OutlineInputBorder())),
                  if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.red))],
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(backgroundColor: widget.branding.primary, foregroundColor: Colors.white),
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                    )),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
