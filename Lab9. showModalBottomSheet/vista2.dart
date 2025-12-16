import 'package:flutter/material.dart';
import 'vista3.dart';

class Vista2 extends StatefulWidget {
  const Vista2({Key? key}) : super(key: key);

  @override
  State<Vista2> createState() => _Vista2State();
}

class _Vista2State extends State<Vista2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 2'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _mostrarBotones(context);
          },
          child: const Text('Mostrar opciones'),
        ),
      ),
    );
  }

  void _mostrarBotones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorButton('Botón Lila', Colors.purple),
              const SizedBox(height: 10),
              _buildColorButton('Botón Rojo', Colors.red),
              const SizedBox(height: 10),
              _buildColorButton('Botón Naranja', Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorButton(String buttonText, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black, // Color del texto negro
        ),
        onPressed: () {
          Navigator.pop(context); // Cerrar el modal
          _navegarAVista3(buttonText.split(' ')[1]); // Extraer el color del botón
        },
        child: Text(buttonText),
      ),
    );
  }

  void _navegarAVista3(String colorSeleccionado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Vista3(colorSeleccionado: colorSeleccionado),
      ),
    );
  }
}