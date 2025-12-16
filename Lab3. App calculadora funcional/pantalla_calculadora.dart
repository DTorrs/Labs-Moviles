import 'package:flutter/material.dart';
import 'controlador_calculadora.dart';

class PantallaCalculadora extends StatelessWidget {
  final ControladorCalculadora controlador;

  const PantallaCalculadora({
    super.key,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controlador.controladorTexto,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.right,
        readOnly: true,
      ),
    );
  }
}