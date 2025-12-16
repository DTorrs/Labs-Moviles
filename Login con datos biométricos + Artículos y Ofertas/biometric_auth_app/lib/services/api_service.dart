import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/articulo.dart';
import 'auth_service.dart';

class ApiService {
  // Servicio singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // URL de la API de artículos (usando npoint.io como ejemplo)
  //static const String articulosUrl = 'https://api.npoint.io/88abc1f40845fe530fd4';
  static const String articulosUrl = 'https://api.npoint.io/d65ed1dd37db6020f714';
  
  // Servicio de autenticación para obtener el token
  final AuthService _authService = AuthService();

  // Método para obtener todos los artículos
  Future<List<Articulo>> obtenerArticulos() async {
    try {
      // Obtenemos el token JWT de la sesión actual
      final token = await _authService.getSessionToken();
      
      if (token == null) {
        throw Exception('No hay una sesión activa');
      }
      
      // Hacemos la petición incluyendo el token en los headers
      final response = await http.get(
        Uri.parse(articulosUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['resultado'] == 'ok') {
          final List<dynamic> articulosJson = data['articulos'];
          return articulosJson.map((json) => Articulo.fromJson(json)).toList();
        } else {
          throw Exception('Respuesta no válida de la API');
        }
      } else if (response.statusCode == 401) {
        // Error de autenticación
        throw Exception('Sesión expirada o inválida. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para obtener solo las ofertas (artículos con descuento)
  Future<List<Articulo>> obtenerOfertas() async {
    final articulos = await obtenerArticulos();
    return articulos.where((articulo) => articulo.tieneDescuento()).toList();
  }
}