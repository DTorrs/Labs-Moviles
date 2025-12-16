import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vista2.dart';
import 'vista3.dart';

class Vista1 extends StatelessWidget {
  const Vista1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 1'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                foregroundColor: Colors.black, 
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Vista2(),
                    settings: const RouteSettings(arguments: 'hola'),
                  ),
                );
              },
              child: const Text('Ir a Vista 2 (push)'),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                foregroundColor: Colors.black, // Color del texto negro
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/vista2',
                  arguments: 'hola',
                );
              },
              child: const Text('Ir a Vista 2 (pushNamed)'),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                foregroundColor: Colors.black, // Color del texto negro
              ),
              onPressed: () async {
                final resultado = await Get.to(() => const Vista3());
                if (resultado != null) {
                  Get.snackbar(
                    'Respuesta',
                    'Valor retornado: $resultado',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Ir a Vista 3 (Get.to)'),
            ),
          ],
        ),
      ),
    );
  }
}