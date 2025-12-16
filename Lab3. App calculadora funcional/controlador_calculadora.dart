import 'package:flutter/material.dart';

class ControladorCalculadora {
  final controladorTexto = TextEditingController(text: '0');
  String numeroActual = '0';
  double? primerNumero;
  String? operacion;
  bool debeResetearPantalla = false;

  void agregarNumero(String numero) {
    if (debeResetearPantalla) {
      controladorTexto.text = numero;
      debeResetearPantalla = false;
    } else {
      if (numero == '.') {
        if (!controladorTexto.text.contains('.')) {
          controladorTexto.text += numero;
        }
      } else {
        if (controladorTexto.text == '0' && numero != '.') {
          controladorTexto.text = numero;
        } else {
          controladorTexto.text += numero;
        }
      }
    }
    numeroActual = controladorTexto.text;
  }

  void agregarOperacion(String operacionNueva) {
    primerNumero = double.parse(numeroActual);
    operacion = operacionNueva;
    debeResetearPantalla = true;
  }

  void calcularResultado() {
    if (primerNumero == null || operacion == null) return;

    final double segundoNumero = double.parse(numeroActual);
    double resultado = 0;

    switch (operacion) {
      case '+':
        resultado = primerNumero! + segundoNumero;
        break;
      case '-':
        resultado = primerNumero! - segundoNumero;
        break;
      case '×':
        resultado = primerNumero! * segundoNumero;
        break;
      case '÷':
        if (segundoNumero != 0) {
          resultado = primerNumero! / segundoNumero;
        } else {
          controladorTexto.text = 'Error';
          return;
        }
        break;
    }

    String resultadoTexto = resultado.toString();
    if (resultadoTexto.endsWith('.0')) {
      resultadoTexto = resultadoTexto.substring(0, resultadoTexto.length - 2);
    }
    controladorTexto.text = resultadoTexto;
    numeroActual = resultadoTexto;
    operacion = null;
    primerNumero = null;
  }

  void limpiar() {
    controladorTexto.text = '0';
    numeroActual = '0';
    primerNumero = null;
    operacion = null;
    debeResetearPantalla = false;
  }

  void borrarUltimo() {
    if (controladorTexto.text.length > 1) {
      controladorTexto.text = 
          controladorTexto.text.substring(0, controladorTexto.text.length - 1);
    } else {
      controladorTexto.text = '0';
    }
    numeroActual = controladorTexto.text;
  }

  void calcularPorcentaje() {
    if (controladorTexto.text != 'Error') {
      double numero = double.parse(controladorTexto.text);
      
      if (primerNumero != null && operacion != null) {
        double resultado = 0;
        switch (operacion) {
          case '+':
            resultado = primerNumero! + (primerNumero! * numero / 100);
            break;
          case '-':
            resultado = primerNumero! - (primerNumero! * numero / 100);
            break;
          case '×':
            resultado = primerNumero! * (numero / 100);
            break;
          case '÷':
            if (numero != 0) {
              resultado = primerNumero! / (numero / 100);
            } else {
              controladorTexto.text = 'Error';
              return;
            }
            break;
        }
        String resultadoTexto = resultado.toString();
        if (resultadoTexto.endsWith('.0')) {
          resultadoTexto = resultadoTexto.substring(0, resultadoTexto.length - 2);
        }
        controladorTexto.text = resultadoTexto;
        numeroActual = resultadoTexto;
      } else {
        double resultado = numero / 100;
        String resultadoTexto = resultado.toString();
        if (resultadoTexto.endsWith('.0')) {
          resultadoTexto = resultadoTexto.substring(0, resultadoTexto.length - 2);
        }
        controladorTexto.text = resultadoTexto;
        numeroActual = resultadoTexto;
      }
    }
  }

  void dispose() {
    controladorTexto.dispose();
  }
}