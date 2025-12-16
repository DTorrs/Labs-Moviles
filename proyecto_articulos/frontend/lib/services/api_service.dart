import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/article.dart';

class ApiService {
  // URL base de la API - Usar 10.0.2.2 para emulador Android
  final String baseUrl = 'http://10.0.2.2:3000/api'; // Para emulador Android
  // final String baseUrl = 'http://localhost:3000/api'; // Para iOS simulator
  
  // Almacenamiento seguro para el token
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  
  // Obtener token de autenticación
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: 'jwt_token');
    } catch (e) {
      debugPrint('Error al leer token: $e');
      return null;
    }
  }
  
  // Guardar token de autenticación
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: 'jwt_token', value: token);
    } catch (e) {
      debugPrint('Error al guardar token: $e');
    }
  }
  
  // Eliminar token (cerrar sesión)
  Future<void> deleteToken() async {
    try {
      await secureStorage.delete(key: 'jwt_token');
    } catch (e) {
      debugPrint('Error al eliminar token: $e');
    }
  }
  
  // Cabeceras HTTP
  Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    try {
      String? token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Error al obtener headers: $e');
    }
    
    return headers;
  }
  
  // Registro de usuario
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      debugPrint('Intentando registrar usuario: $username, $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Respuesta: ${response.body}');
      
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error al decodificar respuesta: $e');
        responseData = {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor'
        };
      }
      
      if (response.statusCode == 201) {
        // Solo guardar token si está presente
        if (responseData['token'] != null && responseData['token'] is String) {
          await saveToken(responseData['token']);
        }
        
        return {
          'success': true,
          'user': User.fromJson(responseData['user']),
          'token': responseData['token'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      debugPrint('Error en register: $e');
      return {
        'success': false,
        'message': 'Error en el registro: ${e.toString()}',
      };
    }
  }
  
  // Iniciar sesión
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('Intentando iniciar sesión: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Respuesta: ${response.body}');
      
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error al decodificar respuesta: $e');
        responseData = {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor'
        };
      }
      
      if (response.statusCode == 200) {
        // Solo guardar token si está presente
        if (responseData['token'] != null && responseData['token'] is String) {
          await saveToken(responseData['token']);
        }
        
        // Crear un usuario incluso si user es null
        User user = responseData['user'] != null 
          ? User.fromJson(responseData['user'])
          : User.defaultUser();
        
        return {
          'success': true,
          'user': user,
          'token': responseData['token'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      return {
        'success': false,
        'message': 'Error en el inicio de sesión: ${e.toString()}',
      };
    }
  }
  
  // Obtener información del usuario actual
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(),
      );
      
      debugPrint('getCurrentUser - Código: ${response.statusCode}');
      
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error al decodificar respuesta: $e');
        return {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor'
        };
      }
      
      if (response.statusCode == 200) {
        // Crear un usuario incluso si user es null
        User user = responseData['user'] != null 
          ? User.fromJson(responseData['user'])
          : User.defaultUser();
        
        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al obtener usuario',
        };
      }
    } catch (e) {
      debugPrint('Error en getCurrentUser: $e');
      return {
        'success': false,
        'message': 'Error al obtener información del usuario: ${e.toString()}',
      };
    }
  }
  
  // Resto del código...
  
  // Obtener todos los artículos
  Future<List<Article>> getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesJson = data['data'] ?? [];
        
        return articlesJson
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        debugPrint('Error al obtener artículos: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error en getArticles: $e');
      return [];
    }
  }
  
  // Obtener favoritos (desde la API)
  Future<List<Article>> getFavoriteArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles/user/favorites'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesJson = data['data'] ?? [];
        
        return articlesJson
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        debugPrint('Error al obtener favoritos: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error en getFavoriteArticles: $e');
      return [];
    }
  }
  
 // Agregar artículo a favoritos - versión mejorada
  Future<Map<String, dynamic>> addToFavorites(int articleId) async {
    try {
      debugPrint('📡 Agregando artículo $articleId a favoritos (API)');
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'articleId': articleId,
        }),
      );
      
      debugPrint('📡 Respuesta: ${response.statusCode} - ${response.body}');
      
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        debugPrint('📡 Error al decodificar respuesta: $e');
        return {
          'success': false,
          'message': 'Error al procesar la respuesta del servidor'
        };
      }
      
      // Considerar tanto 200 (ya existe) como 201 (creado) como éxito
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'favoriteId': responseData['data']?['id'] ?? 1, // Usar 1 como valor por defecto si no hay ID
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al agregar a favoritos',
        };
      }
    } catch (e) {
      debugPrint('📡 Error en addToFavorites: $e');
      return {
        'success': false,
        'message': 'Error al agregar a favoritos: ${e.toString()}',
      };
    }
  }
  
   // Eliminar artículo de favoritos - versión mejorada
  Future<bool> removeFromFavorites(int articleId) async {
    try {
      debugPrint('📡 Eliminando artículo $articleId de favoritos (API)');
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$articleId'),
        headers: await _getHeaders(),
      );
      
      debugPrint('📡 Respuesta: ${response.statusCode} - ${response.body}');
      
      // Considerar tanto 200 (eliminado) como 404 (no existe) como éxito
      // Ya que el resultado final es el mismo: no está en favoritos
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      debugPrint('📡 Error en removeFromFavorites: $e');
      // Devolver true para permitir la eliminación local incluso si falla el API
      // Esto es para mantener la consistencia de la UI
      return true;
    }
  }
}