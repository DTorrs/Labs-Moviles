import 'package:flutter/material.dart';

class VistaDetalle extends StatelessWidget {
  const VistaDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    final persona = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(title: Text(persona['nombreCompleto'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(persona['urlImagen']),
              ),
            ),
            const SizedBox(height: 20),
            Text('Profesión: ${persona['profesion']}', style: estiloTexto),
            Text('Edad: ${persona['edad']} años', style: estiloTexto),
            Text(
              'Universidad: ${persona['estudios'][0]['universidad']}',
              style: estiloTexto,
            ),
            Text(
              'Bachillerato: ${persona['estudios'][0]['bachillerato']}',
              style: estiloTexto,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Regresar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const estiloTexto = TextStyle(fontSize: 18);
