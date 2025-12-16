import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/api_service.dart';
import '../widgets/item_articulo.dart';

class ListaOfertas extends StatefulWidget {
  const ListaOfertas({Key? key}) : super(key: key);

  @override
  State<ListaOfertas> createState() => _ListaOfertasState();
}

class _ListaOfertasState extends State<ListaOfertas> {
  final ApiService _apiService = ApiService();
  late Future<List<Articulo>> _futureOfertas;

  @override
  void initState() {
    super.initState();
    _futureOfertas = _apiService.obtenerOfertas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Articulo>>(
        future: _futureOfertas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar ofertas: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureOfertas = _apiService.obtenerOfertas();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay ofertas disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final ofertas = snapshot.data!;
            return ListView.builder(
              itemCount: ofertas.length,
              itemBuilder: (context, index) {
                return ItemArticulo(
                  articulo: ofertas[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/ficha_articulo',
                      arguments: ofertas[index],
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}