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
      
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Obtener las opciones biométricas disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Autenticar con biometría
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autentícate para iniciar sesión',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        return false;
      }
      return false;
    }
  }

  // Guardar credenciales para uso biométrico
  Future<void> saveBiometricCredentials(String username, String password) async {
    final credentials = '$username|$password';
    await _secureStorage.write(key: _credsKey, value: credentials);
  }

  // Eliminar credenciales biométricas
  Future<void> deleteBiometricCredentials() async {
    await _secureStorage.delete(key: _credsKey);
  }

  // Obtener credenciales guardadas
  Future<Map<String, String>?> getBiometricCredentials() async {
    final credentials = await _secureStorage.read(key: _credsKey);
    
    if (credentials == null || !credentials.contains('|')) {
      return null;
    }
    
    final parts = credentials.split('|');
    return {
      'username': parts[0],
      'password': parts[1],
    };
  }

  // Verificar si hay credenciales biométricas guardadas
  Future<bool> hasBiometricCredentials() async {
    final credentials = await _secureStorage.read(key: _credsKey);
    return credentials != null;
  }
}