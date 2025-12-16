import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/articulo.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/item_articulo.dart';
import 'ficha_articulo.dart';
import 'login_screen.dart';

class ArticulosScreen extends StatefulWidget {
  final String titulo;
  final Color colorFondo;
  final bool soloOfertas;
  final IconData iconoVacio;
  final String mensajeVacio;

  const ArticulosScreen({
    Key? key,
    required this.titulo,
    required this.colorFondo,
    this.soloOfertas = false,
    this.iconoVacio = Icons.shopping_bag_outlined,
    this.mensajeVacio = 'No se encontraron artículos',
  }) : super(key: key);

  @override
  State<ArticulosScreen> createState() => _ArticulosScreenState();
}

class _ArticulosScreenState extends State<ArticulosScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Articulo>> _futureArticulos;
  bool _isSessionExpired = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _isSessionExpired = false;
      // Reutilizamos el mismo método pero con lógica condicional
      _futureArticulos = widget.soloOfertas
          ? _apiService.obtenerOfertas()
          : _apiService.obtenerArticulos();
    });
  }

  // Método para manejar el error de sesión expirada
  void _handleSessionExpired() {
    setState(() {
      _isSessionExpired = true;
    });
    
    // Mostramos un dialog informando al usuario
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesión expirada'),
        content: const Text('Tu sesión ha expirado o es inválida. Por favor, inicia sesión nuevamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerramos el diálogo
              
              // Cerramos sesión
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout().then((_) {
                // Navegamos a la pantalla de login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: widget.colorFondo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSessionExpired
          ? _construirEstadoSesionExpirada()
          : FutureBuilder<List<Articulo>>(
              future: _futureArticulos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Verificamos si es un error de autenticación
                  final error = snapshot.error.toString();
                  if (error.contains('Sesión expirada') || 
                      error.contains('inválida') || 
                      error.contains('No hay una sesión activa')) {
                    // Si es error de autenticación, manejamos la sesión expirada
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _handleSessionExpired();
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _construirEstadoError(error);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _construirEstadoVacio();
                } else {
                  return _construirListaArticulos(snapshot.data!);
                }
              },
            ),
    );
  }

  Widget _construirEstadoSesionExpirada() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Sesión expirada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Cerramos sesión y volvemos a la pantalla de login
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            },
            child: const Text('Ir a iniciar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cargarDatos();
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.iconoVacio,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            widget.mensajeVacio,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _construirListaArticulos(List<Articulo> articulos) {
    return ListView.builder(
      itemCount: articulos.length,
      itemBuilder: (context, index) {
        return ItemArticulo(
          articulo: articulos[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FichaArticulo(
                  articulo: articulos[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}