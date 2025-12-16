import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'firebase_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  
  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
  
  // Obtener email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
  
  // Registrar usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required File? photo,
  }) async {
    // Obtener token FCM
    final fcmToken = await _firebaseService.getToken();
    
    if (fcmToken == null) {
      return {
        'success': false,
        'message': 'No se pudo obtener el token de notificaciones',
      };
    }
    
    // Llamar al servicio API para registrar
    return await _apiService.register(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      photo: photo,
      fcmToken: fcmToken,
    );
  }
  
  // Iniciar sesión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Obtener token FCM
    final fcmToken = await _firebaseService.getToken();
    
    if (fcmToken == null) {
      return {
        'success': false,
        'message': 'No se pudo obtener el token de notificaciones',
      };
    }
    
    // Llamar al servicio API para iniciar sesión
    return await _apiService.login(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    await _apiService.logout();
    await _firebaseService.deleteToken();
  }
}