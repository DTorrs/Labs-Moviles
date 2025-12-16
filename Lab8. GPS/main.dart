import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Localización',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Localización GPS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _ubicacion = "Sin ubicación";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tu ubicación actual:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              _ubicacion,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _obtenerYMostrarUbicacion,
                    child: const Text('Obtener Ubicación'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _ubicacion != "Sin ubicación" ? _abrirMapa : null,
              child: const Text('Abrir en Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para obtener la ubicación GPS
  Future<void> _obtenerYMostrarUbicacion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position posicion = await obtenerGps();
      setState(() {
        _ubicacion = "${posicion.latitude},${posicion.longitude}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ubicacion = "Error: $e";
        _isLoading = false;
      });
      _mostrarError(e.toString());
    }
  }

  // Función para abrir Google Maps con la ubicación actual
  Future<void> _abrirMapa() async {
    if (_ubicacion != "Sin ubicación" && !_ubicacion.contains("Error")) {
      String url = "http://www.google.com/maps/place/$_ubicacion";
      try {
        await abrirUrl(url);
      } catch (e) {
        _mostrarError("No se pudo abrir el mapa: $e");
      }
    }
  }

  // Mostrar diálogo de error
  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // Función para obtener GPS (de la guía proporcionada)
  Future<Position> obtenerGps() async {
    // Verificar si la ubicación del dispositivo está habilitada
    bool bGpsHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!bGpsHabilitado) {
      return Future.error('Por favor habilite el servicio de ubicación.');
    }
    
    // Validar permiso para utilizar los servicios de localización
    LocationPermission bGpsPermiso = await Geolocator.checkPermission();
    if (bGpsPermiso == LocationPermission.denied) {
      bGpsPermiso = await Geolocator.requestPermission();
      if (bGpsPermiso == LocationPermission.denied) {
        return Future.error('Se denegó el permiso para obtener la ubicación.');
      }
    }
    
    if (bGpsPermiso == LocationPermission.deniedForever) {
      return Future.error('Se denegó el permiso para obtener la ubicación de forma permanente.');
    }
    
    // En este punto los permisos están habilitados y se puede consultar la ubicación
    return await Geolocator.getCurrentPosition();
  }

  // Función para abrir URL (de la guía proporcionada)
  Future<void> abrirUrl(final String sUrl) async {
    final Uri oUri = Uri.parse(sUrl);
    try {
      await launchUrl(
        oUri, // Ej: http://www.google.com/maps/place/6.2502089,-75.5706711
        mode: LaunchMode.externalApplication
      );
    } catch (oError) {
      return Future.error('No fue posible abrir la url: $sUrl.');
    }
  }
}