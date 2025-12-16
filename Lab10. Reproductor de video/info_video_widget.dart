import 'package:flutter/material.dart';

class InfoVideoWidget extends StatelessWidget {
  final String nombre;
  final String duracion;
  final String tamano;

  const InfoVideoWidget({
    Key? key, 
    required this.nombre, 
    required this.duracion, 
    required this.tamano
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nombre: $nombre",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tiempo: $duracion",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "Tamaño: $tamano",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}