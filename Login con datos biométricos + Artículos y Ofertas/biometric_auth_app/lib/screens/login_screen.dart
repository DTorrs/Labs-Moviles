import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../services/biometric_service.dart';
import 'menu_principal.dart'; // Importamos el menú principal en lugar de home_screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;
  bool _showBiometricButton = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isInitializing = true;
    });
    
    // Retrasar un poco para asegurarnos de que el Provider está listo
    await Future.delayed(const Duration(milliseconds: 100));
    await _checkBiometricStatus();
    
    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _checkBiometricStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Verificar si la biometría está disponible y habilitada
      final biometricAvailable = authProvider.biometricAvailable;
      
      if (biometricAvailable) {
        final biometricService = BiometricService();
        
        // Verificar si hay credenciales almacenadas
        final hasBiometricCredentials = await biometricService.hasBiometricCredentials();
        
        // Verificar si hay biometría disponible en el dispositivo
        final availableBiometrics = await biometricService.getAvailableBiometrics();
        
        print("Verificación biométrica completa:");
        print("- Disponible: $biometricAvailable");
        print("- Credenciales guardadas: $hasBiometricCredentials");
        print("- Biometrías disponibles: $availableBiometrics");
        
        // Solo mostrar el botón si hay credenciales y biometría disponible
        setState(() {
          _showBiometricButton = biometricAvailable && 
                               hasBiometricCredentials && 
                               availableBiometrics.isNotEmpty;
        });
        
        print("¿Mostrar botón biométrico? $_showBiometricButton");
      } else {
        setState(() {
          _showBiometricButton = false;
        });
      }
    } catch (e) {
      print("Error al verificar estado biométrico: $e");
      setState(() {
        _showBiometricButton = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  // Modificamos este método para que navegue al menú principal en lugar de home_screen
  void _navigateToMenuPrincipal() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MenuPrincipal()),
    );
  }

Future<void> _loginWithBiometric() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  try {
    print("Intentando iniciar sesión con biometría...");
    final success = await authProvider.loginWithBiometric();
    print("Resultado de inicio de sesión biométrico: $success");
    
    if (success && mounted) {
      _navigateToMenuPrincipal(); // Navegar al menú principal
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al iniciar sesión con biometría'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("Error en _loginWithBiometric: $e");
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _checkBiometricDetails() async {
    try {
      final biometricService = BiometricService();
      final isAvailable = await biometricService.isBiometricAvailable();
      final types = await biometricService.getAvailableBiometrics();
      final hasCreds = await biometricService.hasBiometricCredentials();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Estado biométrico'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disponible: $isAvailable'),
              Text('Tipos: $types'),
              Text('Credenciales guardadas: $hasCreds'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un spinner de carga mientras se inicializa
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando autenticación biométrica...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o imagen
                const Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                
                // Botón para comprobar estado biométrico (útil para diagnóstico)
                TextButton.icon(
                  onPressed: _checkBiometricDetails,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Verificar estado biométrico'),
                ),

                // Mostrar prominentemente el botón biométrico si está disponible
                if (_showBiometricButton && !_isRegistering) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: _loginWithBiometric,
                      icon: const Icon(Icons.fingerprint, size: 28),
                      label: const Text(
                        'Iniciar sesión con huella',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('o inicia sesión con usuario y contraseña'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Formulario de login/registro
                LoginForm(
                  isRegister: _isRegistering,
                  onToggleMode: _toggleMode,
                  onLoginSuccess: _navigateToMenuPrincipal, // Modificado
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}