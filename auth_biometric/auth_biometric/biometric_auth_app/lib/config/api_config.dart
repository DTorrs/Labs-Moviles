class ApiConfig {
  // Usa la IP de tu computadora
  static const String baseUrl = 'http://192.168.1.22:5000/api';
  
  // Rutas de autenticación
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String toggleBiometric = '$baseUrl/auth/biometric';
}