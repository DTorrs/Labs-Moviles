import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class ApiService {
  // Cambiar por la URL de tu API
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Obtener token JWT almacenado
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Headers con token JWT para autenticación
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Registrar usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required File? photo,
    required String fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    
    try {
      final request = http.MultipartRequest('POST', url);
      
      // Agregar campos de texto
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['fullName'] = fullName;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['role'] = role;
      request.fields['fcmToken'] = fcmToken;
      
      // Agregar foto si existe
      if (photo != null) {
        final file = await http.MultipartFile.fromPath('photo', photo.path);
        request.files.add(file);
      }
      
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = json.decode(responseString);
      
      if (response.statusCode == 201) {
        // Guardar token JWT
        if (responseData.containsKey('token')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
        }
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Iniciar sesión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        }),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Guardar token JWT
        if (responseData.containsKey('token')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          
          // También guardamos el email del usuario
          if (responseData.containsKey('user') && 
              responseData['user'].containsKey('email')) {
            await prefs.setString('userEmail', responseData['user']['email']);
          }
        }
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userEmail');
  }
  
  // Obtener lista de usuarios
  Future<Map<String, dynamic>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final List<User> users = (responseData['users'] as List)
            .map((userData) => User.fromJson(userData))
            .toList();
        
        return {
          'success': true,
          'data': users,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al obtener usuarios',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Obtener perfil de usuario
  Future<Map<String, dynamic>> getUserProfile(String email) async {
    final url = Uri.parse('$baseUrl/users/$email');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': User.fromJson(responseData['user']),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al obtener perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Enviar mensaje
  Future<Map<String, dynamic>> sendMessage({
    required String title,
    required String body,
    required String receiverEmail,
  }) async {
    final url = Uri.parse('$baseUrl/messages/send');
    
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'title': title,
          'body': body,
          'receiverEmail': receiverEmail,
        }),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al enviar mensaje',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Obtener mensajes recibidos
  Future<Map<String, dynamic>> getReceivedMessages() async {
    final url = Uri.parse('$baseUrl/messages/received');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final List<Message> messages = (responseData['messages'] as List)
            .map((messageData) => Message.fromJson(messageData))
            .toList();
        
        return {
          'success': true,
          'data': messages,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al obtener mensajes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // Actualizar token FCM
  Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    final url = Uri.parse('$baseUrl/users/fcm-token');
    
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'fcmToken': fcmToken,
        }),
      );
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al actualizar token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}