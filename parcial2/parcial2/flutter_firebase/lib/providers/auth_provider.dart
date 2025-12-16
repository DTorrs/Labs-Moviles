import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Inicializar estado desde SharedPreferences
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isAuthenticated = await _authService.isAuthenticated();
      
      if (_isAuthenticated) {
        final email = await _authService.getCurrentUserEmail();
        
        if (email != null) {
          final response = await _apiService.getUserProfile(email);
          
          if (response['success']) {
            _currentUser = response['data'];
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Registrar usuario
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required File? photo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        photo: photo,
      );
      
      if (response['success']) {
        _isAuthenticated = true;
        _currentUser = User(
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          role: role,
          photoUrl: null, // Se actualizará después
        );
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      if (response['success']) {
        _isAuthenticated = true;
        _currentUser = User.fromJson(response['data']['user']);
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
      _isAuthenticated = false;
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}