import 'package:flutter/material.dart';
import 'calculadora.dart';

class AppCalculadora extends StatelessWidget {
  const AppCalculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: const VentanaCalculadora(),
    );
  }
}