import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../base/base_screen.dart';
import '../base/app_router.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({Key? key, Map<String, dynamic>? params}) : super(key: key, params: params);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showLoadingIndicator();
    clearErrorMessage();

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Imprimir para depuración
      debugPrint('Intentando iniciar sesión con: ${_emailController.text.trim()}');
      
      final response = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;

      if (response['success'] == true) {
        // Navegamos a la pantalla de artículos
        AppRouter.navigateToArticles(context);
      } else {
        setErrorMessage(response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      debugPrint('Error capturado en login: $e');
      setErrorMessage('Error al iniciar sesión: ${e.toString()}');
    } finally {
      hideLoadingIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraer los parámetros o usar valores predeterminados
    final logoIcon = widget.params?['logoIcon'] ?? Icons.shopping_bag;
    final logoColor = widget.params?['logoColor'] ?? Colors.blue;
    final appTitle = widget.params?['appTitle'] ?? 'Iniciar Sesión';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  logoIcon,
                  size: 80,
                  color: logoColor,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor ingrese un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Widget reutilizable para mostrar errores
                buildErrorMessage(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    AppRouter.navigateToRegister(context);
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}