import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Clave para almacenar las credenciales
  static const String _credsKey = 'biometric_credentials';

  // Verificar si el dispositivo soporta biometría
  Future<bool> isBiometricAvailable() async {
    try {
      // Verificar si el hardware soporta biometría
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      print("Hardware biométrico - Puede verificar: $canCheckBiometrics, Soportado: $isDeviceSupported");
      
      if (canCheckBiometrics && isDeviceSupported) {
        List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        print("Biometrías disponibles: $availableBiometrics");
      }
      
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print("Error al verificar disponibilidad biométrica: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Obtener las opciones biométricas disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      List<BiometricType> biometrics = await _localAuth.getAvailableBiometrics();
      print("Biometrías disponibles: $biometrics");
      return biometrics;
    } on PlatformException catch (e) {
      print("Error al obtener biometrías disponibles: ${e.code} - ${e.message}");
      return [];
    }
  }

  // Autenticar con biometría
  Future<bool> authenticate() async {
    try {
      print('Solicitando autenticación biométrica...');
      bool result = await _localAuth.authenticate(
        localizedReason: '¡Usa tu huella para iniciar sesión!',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
      );
      print('Resultado de autenticación biométrica: $result');
      return result;
    } on PlatformException catch (e) {
      print('Error de autenticación biométrica: ${e.code} - ${e.message}');
      if (e.code == auth_error.notAvailable || e.code == auth_error.notEnrolled) {
        throw Exception('La autenticación biométrica no está configurada en el dispositivo.');
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        throw Exception('Demasiados intentos fallidos. Intenta más tarde o usa tu contraseña.');
      } else {
        throw Exception('Error al autenticar: ${e.message}');
      }
    }
  }

  // Guardar credenciales para uso biométrico
  Future<void> saveBiometricCredentials(String username, String password) async {
    try {
      print("Guardando credenciales biométricas para: $username");
      final credentials = '$username|$password';
      await _secureStorage.write(key: _credsKey, value: credentials);
      
      // Verificar que se guardaron correctamente
      final saved = await _secureStorage.read(key: _credsKey);
      if (saved == null) {
        throw Exception("No se pudieron guardar las credenciales");
      }
      print("Credenciales biométricas guardadas correctamente");
    } catch (e) {
      print("Error al guardar credenciales biométricas: $e");
      throw Exception("Error al guardar credenciales biométricas: $e");
    }
  }

  // Eliminar credenciales biométricas
  Future<void> deleteBiometricCredentials() async {
    try {
      await _secureStorage.delete(key: _credsKey);
      print("Credenciales biométricas eliminadas");
    } catch (e) {
      print("Error al eliminar credenciales biométricas: $e");
      throw e;
    }
  }

  // Obtener credenciales guardadas
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final credentials = await _secureStorage.read(key: _credsKey);
      print("Recuperando credenciales biométricas: ${credentials != null ? 'Encontradas' : 'No encontradas'}");
      
      if (credentials == null || !credentials.contains('|')) {
        print("No se encontraron credenciales biométricas válidas");
        return null;
      }
      
      final parts = credentials.split('|');
      if (parts.length != 2) {
        print("Formato de credenciales inválido");
        return null;
      }
      
      return {
        'username': parts[0],
        'password': parts[1],
      };
    } catch (e) {
      print("Error al recuperar credenciales biométricas: $e");
      return null;
    }
  }

  // Verificar si hay credenciales biométricas guardadas
  Future<bool> hasBiometricCredentials() async {
    try {
      final credentials = await _secureStorage.read(key: _credsKey);
      final hasValidCreds = credentials != null && credentials.contains('|');
      print("Verificando credenciales biométricas: ${hasValidCreds ? 'Existen' : 'No existen'}");
      return hasValidCreds;
    } catch (e) {
      print("Error al verificar credenciales biométricas: $e");
      return false;
    }
  }
  // Añadir un método para guardar el token biométrico
Future<void> saveBiometricToken(String token) async {
  try {
    await _secureStorage.write(key: 'biometric_token', value: token);
    print("Token biométrico guardado");
  } catch (e) {
    print("Error al guardar token biométrico: $e");
    throw e;
  }
}

// Obtener el token biométrico
Future<String?> getBiometricToken() async {
  try {
    return await _secureStorage.read(key: 'biometric_token');
  } catch (e) {
    print("Error al recuperar token biométrico: $e");
    return null;
  }
}
}