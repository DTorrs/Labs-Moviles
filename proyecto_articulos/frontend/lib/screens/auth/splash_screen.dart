import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../base/base_screen.dart';
import '../base/app_router.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({Key? key, Map<String, dynamic>? params}) : super(key: key, params: params);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseScreenState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Verificar si la sesión está activa y válida
    bool isSessionValid = await authService.checkSession();
    
    if (isSessionValid) {
      // Verificar si la sesión ha expirado (7 días)
      bool isExpired = await authService.isSessionExpired();
      
      if (isExpired) {
        // Si ha expirado, cerrar sesión y redirigir a login
        await authService.logout();
        if (mounted) {
          AppRouter.navigateToLogin(context);
        }
      } else {
        // Si es válida, ir a pantalla de artículos
        if (mounted) {
          AppRouter.navigateToArticles(context);
        }
      }
    } else {
      // Si no está autenticado, ir a login
      if (mounted) {
        AppRouter.navigateToLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el título personalizado del parámetro o usar el predeterminado
    final appTitle = widget.params?['appTitle'] ?? 'Aplicación de Artículos';
    final logoPath = widget.params?['logoPath'] ?? 'assets/images/logo.png';
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o imagen parametrizada
            Image.asset(
              logoPath,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shopping_cart,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            // Título parametrizado
            Text(
              appTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}