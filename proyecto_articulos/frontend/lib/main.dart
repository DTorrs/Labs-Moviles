import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/articles/articles_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'providers/article_provider.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
      ],
      child: MaterialApp(
        title: 'Aplicación de Artículos',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        // Usamos la SplashScreen parametrizada como pantalla inicial
        home: const SplashScreen(
          params: {
            'appTitle': 'Aplicación de Artículos',
            'logoPath': 'assets/images/logo.png',
          },
        ),
        // Rutas parametrizadas
        routes: {
          '/login': (context) => const LoginScreen(
            params: {
              'logoIcon': Icons.shopping_bag,
              'logoColor': Colors.blue,
            },
          ),
          '/register': (context) => const RegisterScreen(),
          '/articles': (context) => const ArticlesScreen(
            params: {
              'title': 'Artículos',
              'showRefreshButton': true,
            },
          ),
          '/favorites': (context) => const FavoritesScreen(
            params: {
              'title': 'Mis Favoritos',
            },
          ),
        },
      ),
    );
  }
}