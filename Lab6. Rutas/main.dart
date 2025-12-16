import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vista1.dart';
import 'vista2.dart';
import 'vista3.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laboratorio 6: Rutas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Vista1(),
        '/vista2': (context) => const Vista2(),
        '/vista3': (context) => const Vista3(),
      },
    );
  }
}