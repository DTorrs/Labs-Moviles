import 'package:flutter/material.dart';

class Vista2 extends StatelessWidget {
  const Vista2({super.key});

  @override
  Widget build(BuildContext context) {
    final String? parametroRecibido = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 2'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (parametroRecibido != null)
              Text('Parámetro recibido: $parametroRecibido',
                  style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black, 
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Regresar a Vista 1'),
            ),
          ],
        ),
      ),
    );
  }
}