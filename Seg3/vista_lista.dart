import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VistaLista extends StatefulWidget {
  const VistaLista({super.key});

  @override
  _VistaListaState createState() => _VistaListaState();
}

class _VistaListaState extends State<VistaLista> {
  List elementos = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final url = Uri.parse('https://api.npoint.io/5cb393746e518d1d8880');
    final respuesta = await http.get(url);
    if (respuesta.statusCode == 200) {
      setState(() {
        elementos = json.decode(respuesta.body)['elementos'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Personas')),
      body:
          elementos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: elementos.length,
                itemBuilder: (context, index) {
                  final persona = elementos[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(persona['urlImagen']),
                    ),
                    title: Text(persona['nombreCompleto']),
                    subtitle: Text(persona['profesion']),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalle',
                        arguments: persona,
                      );
                    },
                  );
                },
              ),
    );
  }
}
