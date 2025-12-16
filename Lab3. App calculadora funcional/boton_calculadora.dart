import 'package:flutter/material.dart';

class BotonCalculadora extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onPressed;

  const BotonCalculadora({
    super.key,
    required this.texto,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            texto,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }
}