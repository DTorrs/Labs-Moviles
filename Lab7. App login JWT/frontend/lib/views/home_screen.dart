import 'package:flutter/material.dart';
import 'package:flutter_jwt_login/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Has iniciado sesión correctamente'),
      ),
    );
  }
}