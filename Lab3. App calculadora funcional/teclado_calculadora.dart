import 'package:flutter/material.dart';
import 'controlador_calculadora.dart';
import 'boton_calculadora.dart';

class TecladoCalculadora extends StatelessWidget {
  final ControladorCalculadora controlador;

  const TecladoCalculadora({
    super.key,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                BotonCalculadora(
                  texto: 'AC',
                  color: Colors.orange[300]!,
                  onPressed: controlador.limpiar,
                ),
                BotonCalculadora(
                  texto: 'CE',
                  color: Colors.orange[300]!,
                  onPressed: controlador.limpiar,
                ),
                BotonCalculadora(
                  texto: '%',
                  color: Colors.grey[700]!,
                  onPressed: controlador.calcularPorcentaje,
                ),
                BotonCalculadora(
                  texto: '÷',
                  color: Colors.grey[700]!,
                  onPressed: () => controlador.agregarOperacion('÷'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                BotonCalculadora(
                  texto: '7',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('7'),
                ),
                BotonCalculadora(
                  texto: '8',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('8'),
                ),
                BotonCalculadora(
                  texto: '9',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('9'),
                ),
                BotonCalculadora(
                  texto: '×',
                  color: Colors.grey[700]!,
                  onPressed: () => controlador.agregarOperacion('×'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                BotonCalculadora(
                  texto: '4',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('4'),
                ),
                BotonCalculadora(
                  texto: '5',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('5'),
                ),
                BotonCalculadora(
                  texto: '6',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('6'),
                ),
                BotonCalculadora(
                  texto: '-',
                  color: Colors.grey[700]!,
                  onPressed: () => controlador.agregarOperacion('-'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                BotonCalculadora(
                  texto: '1',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('1'),
                ),
                BotonCalculadora(
                  texto: '2',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('2'),
                ),
                BotonCalculadora(
                  texto: '3',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('3'),
                ),
                BotonCalculadora(
                  texto: '+',
                  color: Colors.grey[700]!,
                  onPressed: () => controlador.agregarOperacion('+'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                BotonCalculadora(
                  texto: '0',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('0'),
                ),
                BotonCalculadora(
                  texto: '.',
                  color: Colors.grey[600]!,
                  onPressed: () => controlador.agregarNumero('.'),
                ),
                BotonCalculadora(
                  texto: '=',
                  color: Colors.grey[700]!,
                  onPressed: controlador.calcularResultado,
                ),
                BotonCalculadora(
                  texto: '⌫',
                  color: Colors.grey[700]!,
                  onPressed: controlador.borrarUltimo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}