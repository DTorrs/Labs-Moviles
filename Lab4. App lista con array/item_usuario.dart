import 'package:flutter/material.dart';

class ItemUsuario extends StatelessWidget {
  final String sImagen;
  final String sNombres;
  final String sCarrera;
  final String sPromedio;

  const ItemUsuario({
    super.key,
    required this.sImagen,
    required this.sNombres,
    required this.sCarrera,
    required this.sPromedio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/$sImagen'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sNombres,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sCarrera,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Promedio: $sPromedio',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}