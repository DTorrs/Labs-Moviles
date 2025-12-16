import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Vista3 extends StatelessWidget {
  const Vista3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 3'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black, 
              ),
              onPressed: () {
                Get.back(result: 'mundo');
              },
              child: const Text('Regresar a Vista 1'),
            ),
          ],
        ),
      ),
    );
  }
}