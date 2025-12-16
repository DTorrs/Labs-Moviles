import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // Iniciar sesión
  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final userData = User.fromJson(jsonDecode(response.body));
      await _saveUserData(userData);
      return userData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al iniciar sesión');
    }
  }

  // Registrar nuevo usuario
  Future<User> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final userData = User.fromJson(jsonDecode(response.body));
      await _saveUserData(userData);
      return userData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al registrar usuario');
    }
  }

  // Activar/desactivar autenticación biométrica
  Future<User> toggleBiometric(bool enabled) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final response = await http.put(
      Uri.parse(ApiConfig.toggleBiometric),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'enabled': enabled,
      }),
    );

    if (response.statusCode == 200) {
      // Obtener el usuario actual y actualizar su estado biométrico
      final currentUser = await getUserData();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          biometricEnabled: enabled,
        );
        await _saveUserData(updatedUser);
        return updatedUser;
      } else {
        final userData = User.fromJson(jsonDecode(response.body));
        await _saveUserData(userData);
        return userData;
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al actualizar configuración biométrica');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  // Guardar token y datos del usuario
  Future<void> _saveUserData(User user) async {
    await _secureStorage.write(key: _tokenKey, value: user.token);
    await _secureStorage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Obtener datos del usuario
  Future<User?> getUserData() async {
    final userData = await _secureStorage.read(key: _userDataKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Verificar si hay una sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}