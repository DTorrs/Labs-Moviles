import 'package:flutter/material.dart';
import '../auth/splash_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../articles/articles_screen.dart';
import '../favorites/favorites_screen.dart';

// Clase para manejar la navegación centralizada
class AppRouter {
  // Rutas nombradas para la app
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String articles = '/articles';
  static const String favorites = '/favorites';
  
  // Mapa de rutas - define las rutas nombradas y sus constructores parametrizados
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      articles: (context) => const ArticlesScreen(),
      favorites: (context) => const FavoritesScreen(),
      // No incluimos articleDetail aquí porque requiere parámetros
    };
  }
  
  // Método para manejar rutas desconocidas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
      ),
    );
  }
  
  // Métodos de navegación con parámetros
  static void navigateToSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, splash);
  }
  
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }
  
  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }
  
  static void navigateToArticles(BuildContext context) {
    Navigator.pushReplacementNamed(context, articles);
  }
  
  static void navigateToFavorites(BuildContext context) {
    Navigator.pushNamed(context, favorites);
  }
}