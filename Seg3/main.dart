import 'package:flutter/material.dart';
import 'vista_lista.dart';
import 'vista_detalle.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const VistaLista(),
        '/detalle': (context) => const VistaDetalle(),
      },
    );
  }
}
