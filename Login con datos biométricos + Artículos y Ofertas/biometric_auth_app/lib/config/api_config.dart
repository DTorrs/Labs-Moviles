class ApiConfig {
  // Usa la URL de ngrok
  static const String baseUrl = 'https://e6e6-191-110-104-107.ngrok-free.app/api';
  
  // Rutas de autenticación
  static const String login = '$baseUrl/auth/login';
  static const String loginBiometric = '$baseUrl/auth/login/biometric';
  static const String register = '$baseUrl/auth/register';
  static const String toggleBiometric = '$baseUrl/auth/biometric';
  static const String generateBiometricToken = '$baseUrl/auth/biometric/token';
}