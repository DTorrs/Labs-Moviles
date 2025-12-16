import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get biometricAvailable => _biometricAvailable;

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Inicializar autenticación y verificar biometría
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar si hay sesión activa
      final userData = await _authService.getUserData();
      if (userData != null) {
        _user = userData;
      }

      // Verificar si el dispositivo soporta biometría
      _biometricAvailable = await _biometricService.isBiometricAvailable();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar sesión con credenciales
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(username, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrar nuevo usuario
  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(username, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar sesión con biometría
  Future<bool> loginWithBiometric() async {
    if (!_biometricAvailable) {
      _error = "La biometría no está disponible en este dispositivo";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Autenticar con biometría
      final authenticated = await _biometricService.authenticate();
      
      if (authenticated) {
        // Obtener credenciales guardadas
        final credentials = await _biometricService.getBiometricCredentials();
        
        if (credentials != null) {
          _user = await _authService.login(
            credentials['username']!,
            credentials['password']!,
          );
          return true;
        } else {
          _error = "No hay credenciales biométricas guardadas";
          return false;
        }
      } else {
        _error = "Autenticación biométrica fallida";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar credenciales para uso biométrico
  Future<bool> enableBiometric(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user == null) {
        throw Exception("No hay sesión activa");
      }

      // Guardar credenciales en secure storage
      await _biometricService.saveBiometricCredentials(username, password);
      
      // Activar biometría en el servidor
      _user = await _authService.toggleBiometric(true);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deshabilitar biometría
  Future<bool> disableBiometric() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user == null) {
        throw Exception("No hay sesión activa");
      }

      // Eliminar credenciales guardadas
      await _biometricService.deleteBiometricCredentials();
      
      // Desactivar biometría en el servidor
      _user = await _authService.toggleBiometric(false);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar si la biometría está habilitada para el usuario actual
  Future<bool> isBiometricEnabled() async {
    if (_user == null) return false;
    
    // Verificar si hay credenciales biométricas guardadas
    final hasBiometricCreds = await _biometricService.hasBiometricCredentials();
    
    return _user!.biometricEnabled && hasBiometricCreds;
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}