import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/api_service.dart';
import '../widgets/item_articulo.dart';

class ListaArticulos extends StatefulWidget {
  const ListaArticulos({Key? key}) : super(key: key);

  @override
  State<ListaArticulos> createState() => _ListaArticulosState();
}

class _ListaArticulosState extends State<ListaArticulos> {
  final ApiService _apiService = ApiService();
  late Future<List<Articulo>> _futureArticulos;

  @override
  void initState() {
    super.initState();
    _futureArticulos = _apiService.obtenerArticulos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Artículos'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Articulo>>(
        future: _futureArticulos,
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
                    'Error al cargar datos: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureArticulos = _apiService.obtenerArticulos();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron artículos'));
          } else {
            final articulos = snapshot.data!;
            return ListView.builder(
              itemCount: articulos.length,
              itemBuilder: (context, index) {
                return ItemArticulo(
                  articulo: articulos[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/ficha_articulo',
                      arguments: articulos[index],
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