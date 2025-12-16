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
      // Verificar si hay sesión activa directamente
      final hasSession = await _authService.isLoggedIn();
      
      if (hasSession) {
        // Solo si hay sesión activa, obtenemos datos de usuario
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = userData;
        }
      } else {
        // Si no hay sesión activa, asegurarse de que _user sea null
        _user = null;
      }

      // Verificar si el dispositivo soporta biometría
      _biometricAvailable = await _biometricService.isBiometricAvailable();
      print("Biometría disponible en el dispositivo: $_biometricAvailable");
      
      if (_biometricAvailable) {
        final hasBiometricCreds = await _biometricService.hasBiometricCredentials();
        print("Credenciales biométricas guardadas: $hasBiometricCreds");
      }
    } catch (e) {
      print("Error en _initializeAuth: $e");
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
      print("Login exitoso para el usuario: ${_user!.username}");
      return true;
    } catch (e) {
      print("Error en login: $e");
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
      print("Registro exitoso para el usuario: ${_user!.username}");
      return true;
    } catch (e) {
      print("Error en register: $e");
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
      print("Verificando credenciales biométricas almacenadas...");
      
      // Verificar si hay credenciales guardadas primero
      final hasCredentials = await _biometricService.hasBiometricCredentials();
      if (!hasCredentials) {
        _error = "No has configurado el inicio de sesión biométrico. Configúralo primero en la pantalla de inicio.";
        return false;
      }
      
      print("Credenciales encontradas, solicitando autenticación biométrica...");
      
      // Autenticar con biometría
      final authenticated = await _biometricService.authenticate();
      
      print("Resultado de autenticación biométrica: $authenticated");
      
      if (authenticated) {
        // Iniciar sesión con biometría usando el token biométrico almacenado
        print("Iniciando sesión con token biométrico...");
        _user = await _authService.loginWithBiometric();
        print("Inicio de sesión biométrico exitoso");
        return true;
      } else {
        _error = "Autenticación biométrica cancelada o fallida";
        return false;
      }
    } catch (e) {
      print("Error en loginWithBiometric: $e");
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

      print("Guardando credenciales para uso biométrico...");
      // Guardar credenciales en secure storage
      await _biometricService.saveBiometricCredentials(username, password);
      
      // Verificar que se guardaron correctamente
      final hasCredentials = await _biometricService.hasBiometricCredentials();
      if (!hasCredentials) {
        throw Exception("No se pudieron guardar las credenciales biométricas");
      }
      
      // Generar token biométrico
      print("Generando token biométrico...");
      await _authService.generateBiometricToken();
      
      print("Activando biometría en el servidor...");
      // Activar biometría en el servidor
      _user = await _authService.toggleBiometric(true);
      
      return true;
    } catch (e) {
      print("Error en enableBiometric: $e");
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
      
      // Eliminar token biométrico
      await _authService.deleteBiometricToken();
      
      // Desactivar biometría en el servidor
      _user = await _authService.toggleBiometric(false);
      
      return true;
    } catch (e) {
      print("Error en disableBiometric: $e");
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
      print("Error en logout: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar estado de la sesión (útil cuando la app vuelve a primer plano)
  Future<void> checkSessionStatus() async {
    try {
      // Verificar si hay un token de sesión válido
      final hasValidSession = await _authService.isLoggedIn();
      
      if (!hasValidSession && _user != null) {
        // Si tenemos usuario pero no hay sesión activa, cerramos sesión
        print("Sesión inválida detectada, cerrando sesión");
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      print("Error en checkSessionStatus: $e");
    }
  }

  // Verificar si hay un token de sesión válido
  Future<bool> hasValidSessionToken() async {
    return await _authService.isLoggedIn();
  }

  // Verificar si la biometría está habilitada para el usuario actual
  Future<bool> isBiometricEnabled() async {
    if (_user == null) return false;
    
    // Verificar explícitamente si hay credenciales biométricas guardadas
    final hasBiometricCreds = await _biometricService.hasBiometricCredentials();
    print("isBiometricEnabled - usuario biométrico: ${_user!.biometricEnabled}, credenciales: $hasBiometricCreds");
    
    return _user!.biometricEnabled && hasBiometricCreds;
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}