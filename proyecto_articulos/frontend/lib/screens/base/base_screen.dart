import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../base/app_router.dart';
import '../../providers/article_provider.dart'; // Importar el provider

// Clase base parametrizada para todas las pantallas
abstract class BaseScreen extends StatefulWidget {
  final Map<String, dynamic>? params;
  
  const BaseScreen({
    Key? key, 
    this.params,
  }) : super(key: key);
}

// Clase base para los estados de las pantallas
abstract class BaseScreenState<T extends BaseScreen> extends State<T> with WidgetsBindingObserver {
  // Variables compartidas
  bool isLoading = false;
  String errorMessage = '';
  
  // Métodos comunes de navegación
  void navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  void showLoadingIndicator() {
    setState(() {
      isLoading = true;
    });
  }
  
  void hideLoadingIndicator() {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }
  
  void clearErrorMessage() {
    setState(() {
      errorMessage = '';
    });
  }
  
  // Widget reutilizable para mensajes de error
  Widget buildErrorMessage() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(color: Colors.red[700]),
      ),
    );
  }
  
  // Widget reutilizable para indicador de carga
  Widget buildLoadingIndicator({String message = 'Cargando...'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message)
        ],
      ),
    );
  }
  
  // Widget reutilizable para mensaje de estado vacío
  Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText),
            ),
          ]
        ],
      ),
    );
  }
  
  // Diálogo reutilizable para confirmar acciones
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String cancelText = 'Cancelar',
    String confirmText = 'Confirmar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Método para cerrar sesión común a varias pantallas
  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      title: 'Cerrar Sesión',
      content: '¿Estás seguro de que deseas cerrar sesión?',
      confirmText: 'Cerrar Sesión',
    );
    
    if (confirmed) {
      // Resetear el estado de favoritos en memoria antes de cerrar sesión
      final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
      articleProvider.resetFavorites();
      
      // Cerrar sesión y eliminar token/base de datos
      await Provider.of<AuthService>(context, listen: false).logout();
      
      if (mounted) {
        // Navegar a la pantalla de login
        AppRouter.navigateToLogin(context);
      }
    }
  }
}