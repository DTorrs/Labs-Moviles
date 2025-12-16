import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import 'database_helper.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  User? _currentUser;
  bool _isAuthenticated = false;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  
  // Verificar si la sesión es válida
  Future<bool> checkSession() async {
    try {
      String? token = await _apiService.getToken();
      
      // Si no hay token, no está autenticado
      if (token == null || token.isEmpty) {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
      
      // Verificar si el token ha expirado localmente
      bool hasExpired = false;
      try {
        hasExpired = JwtDecoder.isExpired(token);
      } catch (e) {
        debugPrint('Error al decodificar token: $e');
        // Si hay error al decodificar, verificar con el servidor en lugar de asumir expiración
        hasExpired = false;
      }
      
      if (hasExpired) {
        debugPrint('Token ha expirado localmente');
        await _apiService.deleteToken();
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
      
      // Verificar si la sesión ha expirado localmente (7 días)
      final bool sessionExpired = await isSessionExpired();
      if (sessionExpired) {
        debugPrint('Sesión ha expirado (7 días)');
        await _apiService.deleteToken();
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
      
      // Verificar si el token es válido con el servidor
      try {
        final response = await _apiService.getCurrentUser();
        
        if (response['success'] == true) {
          _currentUser = response['user'];
          _isAuthenticated = true;
          
          // Actualizar fecha de último login exitoso
          await _updateLoginDate();
          
          notifyListeners();
          return true;
        } else {
          // Solo eliminar el token si el error es de autenticación (401)
          if (response['statusCode'] == 401) {
            debugPrint('Token rechazado por el servidor (401)');
            await _apiService.deleteToken();
            _isAuthenticated = false;
            _currentUser = null;
            notifyListeners();
            return false;
          } else {
            // Para otros errores del servidor, mantener el estado de autenticación
            // actual pero retornar true para permitir el acceso offline
            debugPrint('Error del servidor pero manteniendo autenticación local');
            
            // Intentar usar datos en caché si están disponibles
            if (_currentUser != null) {
              _isAuthenticated = true;
              notifyListeners();
              return true;
            }
            
            // Si no hay datos en caché, intentar decodificar el token para obtener información básica
            try {
              Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
              if (decodedToken.containsKey('id') && decodedToken.containsKey('username')) {
                _currentUser = User(
                  id: decodedToken['id'], 
                  username: decodedToken['username'],
                  email: decodedToken['email'] ?? 'email@example.com',
                  createdAt: DateTime.now()
                );
                _isAuthenticated = true;
                notifyListeners();
                return true;
              }
            } catch (e) {
              debugPrint('Error al decodificar token para uso offline: $e');
            }
            
            return false;
          }
        }
      } catch (e) {
        // Error de red o de servidor - mantener sesión si el token no ha expirado
        debugPrint('Error de red en checkSession: $e');
        
        // Intentar usar datos en caché si están disponibles
        if (_currentUser != null) {
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
        
        // Si no hay datos en caché, intentar decodificar el token para obtener información básica
        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          if (decodedToken.containsKey('id') && decodedToken.containsKey('username')) {
            _currentUser = User(
              id: decodedToken['id'], 
              username: decodedToken['username'],
              email: decodedToken['email'] ?? 'email@example.com',
              createdAt: DateTime.now()
            );
            _isAuthenticated = true;
            notifyListeners();
            return true;
          }
        } catch (e) {
          debugPrint('Error al decodificar token para uso offline: $e');
        }
        
        return false;
      }
    } catch (e) {
      debugPrint('Error general en checkSession: $e');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }
  
  // Registrar usuario
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      debugPrint('Intentando registrar: $username, $email');
      final response = await _apiService.register(username, email, password);
      
      debugPrint('Respuesta de registro: $response');
      
      if (response['success'] == true) {
        // Asignar usuario incluso si es null
        _currentUser = response['user'] ?? User.defaultUser();
        _isAuthenticated = true;
        
        // Guardar fecha de inicio de sesión
        await _saveLoginDate();
        
        notifyListeners();
      }
      
      return response;
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
      debugPrint('Intentando login: $email');
      final response = await _apiService.login(email, password);
      
      debugPrint('Respuesta de login: $response');
      
      if (response['success'] == true) {
        // Asignar usuario incluso si es null
        _currentUser = response['user'] ?? User.defaultUser();
        _isAuthenticated = true;
        
        // Guardar fecha de inicio de sesión
        await _saveLoginDate();
        
        notifyListeners();
      }
      
      return response;
    } catch (e) {
      debugPrint('Error en login: $e');
      return {
        'success': false,
        'message': 'Error en el inicio de sesión: ${e.toString()}',
      };
    }
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _apiService.deleteToken();
      await _dbHelper.deleteDatabase();
      
      // Limpiar datos de SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('login_date');
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }
  
  // Guardar fecha de inicio de sesión
  Future<void> _saveLoginDate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('login_date', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error en _saveLoginDate: $e');
    }
  }
  
  // Actualizar fecha de último login exitoso
  Future<void> _updateLoginDate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Solo actualizar si no existe o ha pasado al menos 1 día
      String? loginDateStr = prefs.getString('login_date');
      if (loginDateStr == null) {
        await _saveLoginDate();
        return;
      }
      
      DateTime loginDate;
      try {
        loginDate = DateTime.parse(loginDateStr);
        DateTime now = DateTime.now();
        int hoursDifference = now.difference(loginDate).inHours;
        
        // Actualizar fecha de login si han pasado más de 24 horas
        if (hoursDifference >= 24) {
          await _saveLoginDate();
        }
      } catch (e) {
        debugPrint('Error al parsear fecha de login: $e');
        await _saveLoginDate();
      }
    } catch (e) {
      debugPrint('Error en _updateLoginDate: $e');
    }
  }
  
  // Verificar si la sesión ha expirado (7 días)
  Future<bool> isSessionExpired() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loginDateStr = prefs.getString('login_date');
      
      if (loginDateStr == null) {
        return true;
      }
      
      DateTime loginDate;
      try {
        loginDate = DateTime.parse(loginDateStr);
      } catch (e) {
        debugPrint('Error al parsear fecha de login: $e');
        return true;
      }
      
      DateTime now = DateTime.now();
      
      // Calcular diferencia en días
      int daysDifference = now.difference(loginDate).inDays;
      
      // Sesión expira después de 7 días
      return daysDifference >= 7;
    } catch (e) {
      debugPrint('Error en isSessionExpired: $e');
      return true; // Si hay error, asumir que expiró
    }
  }
}