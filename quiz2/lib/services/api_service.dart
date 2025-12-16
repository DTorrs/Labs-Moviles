import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/articulo.dart';

class ApiService {
  static const String baseUrl = 'https://api.npoint.io/d65ed1dd37db6020f714';

  Future<List<Articulo>> obtenerArticulos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['resultado'] == 'ok') {
          final List<dynamic> articulosJson = data['articulos'];
          return articulosJson.map((json) => Articulo.fromJson(json)).toList();
        } else {
          throw Exception('Respuesta no válida de la API');
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<List<Articulo>> obtenerOfertas() async {
    final articulos = await obtenerArticulos();
    return articulos.where((articulo) => articulo.tieneDescuento()).toList();
  }
}