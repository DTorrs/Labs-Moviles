import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_usuario.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<ItemUsuario> awItems = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    const String sUrl = "https://api.npoint.io/bffbb3b6b3ad5e711dd2";
    
    try {
      final oRespuesta = await http.get(
        Uri.parse(sUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      
      if (oRespuesta.statusCode == 200) {
        dynamic oJsonDatos = jsonDecode(utf8.decode(oRespuesta.bodyBytes));
        
        print("Estructura JSON recibida:");
        print(oJsonDatos);
        
        setState(() {
          if (oJsonDatos is Map && oJsonDatos.containsKey('items')) {
            awItems = (oJsonDatos['items'] as List).map((aItem) => ItemUsuario(
              sImagen: aItem["imagen"].toString(),
              sNombres: aItem["nombre"].toString(), 
              sCarrera: aItem["carrera"].toString(),
              sPromedio: aItem["promedio"].toString(),
            )).toList();
          }
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar datos: ${oRespuesta.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
      print("ERROR AL ENVIAR/RECIBIR SOLICITUD:");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: Colors.purple,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error.isNotEmpty 
          ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
          : awItems.isEmpty
            ? const Center(child: Text('No se encontraron usuarios'))
            : ListView(children: awItems),
    );
  }
}