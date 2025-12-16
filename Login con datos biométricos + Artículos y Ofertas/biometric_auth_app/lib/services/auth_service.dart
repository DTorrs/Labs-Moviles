import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  // Implementación Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Al crear la instancia, aseguramos que no hay token de sesión
    _sessionToken = null;
  }
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Almacenamiento seguro para datos permanentes
  static const String _biometricTokenKey = 'biometric_token';
  static const String _userDataKey = 'user_data';
  
  // SOLO variable en memoria para el token - nunca se guarda
  String? _sessionToken;
  
  // Registrar el inicio de la app para eliminar sesión
  Future<void> registerAppStart() async {
    // Siempre borrar el token de sesión al iniciar la app
    _sessionToken = null;
    print("App iniciada - Sesión limpiada");
  }

  // Iniciar sesión normal
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
      // SOLO guardar en memoria, NUNCA en almacenamiento
      _sessionToken = userData.token;
      // Guardar datos del usuario
      await _saveUserData(userData);
      return userData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al iniciar sesión');
    }
  }

  // Iniciar sesión con biometría
  Future<User> loginWithBiometric() async {
    final biometricToken = await getBiometricToken();
    if (biometricToken == null) {
      throw Exception('No hay token biométrico almacenado');
    }

    final response = await http.post(
      Uri.parse(ApiConfig.loginBiometric),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'biometricToken': biometricToken,
      }),
    );

    if (response.statusCode == 200) {
      final userData = User.fromJson(jsonDecode(response.body));
      // SOLO guardar en memoria
      _sessionToken = userData.token;
      // Guardar datos del usuario
      await _saveUserData(userData);
      return userData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al iniciar sesión con biometría');
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
      // SOLO guardar en memoria
      _sessionToken = userData.token;
      // Guardar datos del usuario
      await _saveUserData(userData);
      return userData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al registrar usuario');
    }
  }

  // Generar token biométrico
  Future<String> generateBiometricToken() async {
    final token = await getSessionToken();
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final response = await http.post(
      Uri.parse(ApiConfig.generateBiometricToken),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final biometricToken = data['biometricToken'];
      await _secureStorage.write(key: _biometricTokenKey, value: biometricToken);
      return biometricToken;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al generar token biométrico');
    }
  }

  // Activar/desactivar autenticación biométrica
  Future<User> toggleBiometric(bool enabled) async {
    final token = await getSessionToken();
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

  // Guardar datos del usuario (sin el token)
  Future<void> _saveUserData(User user) async {
    await _secureStorage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
  }

  // Obtener token de sesión - SOLO desde memoria
  Future<String?> getSessionToken() async {
    return _sessionToken;
  }

  // Eliminar token de sesión
  void clearSessionToken() {
    _sessionToken = null;
  }

  // Cerrar sesión
  Future<void> logout() async {
    clearSessionToken();
    await _secureStorage.delete(key: _userDataKey);
    // No eliminamos el token biométrico para futuros inicios de sesión
  }

  // Obtener token biométrico (este sí se almacena permanentemente)
  Future<String?> getBiometricToken() async {
    return await _secureStorage.read(key: _biometricTokenKey);
  }

  // Eliminar token biométrico
  Future<void> deleteBiometricToken() async {
    await _secureStorage.delete(key: _biometricTokenKey);
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
    return _sessionToken != null;
  }
}