import 'package:flutter/material.dart';

class Vista1 extends StatefulWidget {
  const Vista1({Key? key}) : super(key: key);

  @override
  State<Vista1> createState() => _Vista1State();
}

class _Vista1State extends State<Vista1> {
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _mostrarOpciones(context);
              },
              child: const Text('Mostrar opciones'),
            ),
            const SizedBox(height: 30),
            if (selectedOption.isNotEmpty)
              Text(
                'Opción seleccionada:\n$selectedOption',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpciones(BuildContext context) {
    String tempSeleccion = selectedOption.isEmpty ? 'Azul' : selectedOption;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Amarillo'),
                    value: 'Amarillo',
                    groupValue: tempSeleccion,
                    onChanged: (value) {
                      setModalState(() {
                        tempSeleccion = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Azul'),
                    value: 'Azul',
                    groupValue: tempSeleccion,
                    onChanged: (value) {
                      setModalState(() {
                        tempSeleccion = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Rojo'),
                    value: 'Rojo',
                    groupValue: tempSeleccion,
                    onChanged: (value) {
                      setModalState(() {
                        tempSeleccion = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Verde'),
                    value: 'Verde',
                    groupValue: tempSeleccion,
                    onChanged: (value) {
                      setModalState(() {
                        tempSeleccion = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Naranja'),
                    value: 'Naranja',
                    groupValue: tempSeleccion,
                    onChanged: (value) {
                      setModalState(() {
                        tempSeleccion = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedOption = tempSeleccion;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}