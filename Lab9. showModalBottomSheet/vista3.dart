import 'package:flutter/material.dart';

class Vista3 extends StatelessWidget {
  final String colorSeleccionado;

  const Vista3({Key? key, required this.colorSeleccionado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Botón presionado',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              colorSeleccionado,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}