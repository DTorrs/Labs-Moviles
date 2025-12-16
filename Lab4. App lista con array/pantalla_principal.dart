import 'package:flutter/material.dart';
import 'item_usuario.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de usuarios con la estructura List<Map<String,dynamic>>
    List<Map<String,dynamic>> aItems = [
      {
        "imagen": "1.jpg",
        "nombres": "Diego Torres",
        "carrera": "Ingeniería de sistemas",
        "promedio": 4.8
      },
      {
        "imagen": "2.jpg",
        "nombres": "Andrea Gutierrez",
        "carrera": "Ingeniería civil",
        "promedio": 4.1
      },
      {
        "imagen": "3.jpg",
        "nombres": "Edwin González",
        "carrera": "Negocios internacionales",
        "promedio": 4.0
      }
    ];

    // Array (List) de widgets tipo ItemUsuario usando el bucle for
    List<ItemUsuario> awItems = [];
    for (var ii = 0; ii < aItems.length; ii++) {
      var aItem = aItems[ii];
      awItems.add(
        ItemUsuario(
          sImagen: aItem["imagen"].toString(),
          sNombres: aItem["nombres"].toString(),
          sCarrera: aItem["carrera"].toString(),
          sPromedio: aItem["promedio"].toString(),
        )
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Usuarios'),
          backgroundColor: Colors.purple,
        ),
        body: ListView(
          children: awItems,
        ),
      ),
    );
  }
}