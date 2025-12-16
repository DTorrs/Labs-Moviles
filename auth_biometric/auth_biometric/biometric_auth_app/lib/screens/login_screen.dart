import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;
  bool _showBiometricButton = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Verificar si la biometría está disponible y habilitada
    final biometricAvailable = authProvider.biometricAvailable;
    final biometricEnabled = await authProvider.isBiometricEnabled();
    
    if (biometricAvailable && biometricEnabled) {
      setState(() {
        _showBiometricButton = true;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _loginWithBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithBiometric();
    
    if (success && mounted) {
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Formulario de login/registro
                LoginForm(
                  isRegister: _isRegistering,
                  onToggleMode: _toggleMode,
                  onLoginSuccess: _navigateToHome,
                ),
                
                // Separador para botón biométrico
                if (_showBiometricButton && !_isRegistering) ...[
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('o'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón de autenticación biométrica
                  ElevatedButton.icon(
                    onPressed: _loginWithBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Iniciar con datos biométricos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}