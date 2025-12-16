import 'package:flutter/material.dart';
import 'controlador_calculadora.dart';
import 'pantalla_calculadora.dart';
import 'teclado_calculadora.dart';

class VentanaCalculadora extends StatefulWidget {
  const VentanaCalculadora({super.key});

  @override
  State<VentanaCalculadora> createState() => _EstadoVentanaCalculadora();
}

class _EstadoVentanaCalculadora extends State<VentanaCalculadora> {
  final ControladorCalculadora controlador = ControladorCalculadora();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: PantallaCalculadora(controlador: controlador),
            ),
            Expanded(
              flex: 5,
              child: TecladoCalculadora(controlador: controlador),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }
}