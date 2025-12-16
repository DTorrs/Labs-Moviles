import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class MessageProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Message> _messages = [];
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;
  
  List<Message> get messages => _messages;
  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Cargar usuarios
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getUsers();
      
      if (response['success']) {
        _users = response['data'];
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar perfil de usuario
  Future<void> loadUserProfile(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getUserProfile(email);
      
      if (response['success']) {
        _selectedUser = response['data'];
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Limpiar usuario seleccionado
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
  
  // Cargar mensajes recibidos
  Future<void> loadReceivedMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getReceivedMessages();
      
      if (response['success']) {
        _messages = response['data'];
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Enviar mensaje
  Future<bool> sendMessage({
    required String title,
    required String body,
    required String receiverEmail,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.sendMessage(
        title: title,
        body: body,
        receiverEmail: receiverEmail,
      );
      
      if (response['success']) {
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
  
  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}