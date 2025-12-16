import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/articulo.dart';
import '../widgets/valoracion.dart';

class FichaArticulo extends StatelessWidget {
  const FichaArticulo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final articulo = ModalRoute.of(context)!.settings.arguments as Articulo;
    final double valoracionDouble = articulo.getValoracionCorregida(); // Convertir a escala 0-5
    final bool tieneDescuento = articulo.tieneDescuento();
    final double precioFinal = articulo.getPrecioConDescuento();
    final double precioOriginal = double.parse(articulo.precio);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Artículo'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen
            SizedBox(
              width: double.infinity,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: articulo.urlimagen,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Nombre del artículo
                  Text(
                    articulo.articulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Precio actual con descuento aplicado (si tiene)
                  Row(
                    children: [
                      Text(
                        '\$${precioFinal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      // 5. Porcentaje de descuento (si aplica)
                      if (tieneDescuento)
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${articulo.descuento}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // 4. Precio antes del descuento (si tiene)
                  if (tieneDescuento)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Antes \$${precioOriginal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // 6. Valoración y número de calificaciones
                  Row(
                    children: [
                      Text(
                        valoracionDouble.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Valoracion(
                        valoracion: valoracionDouble,
                        tamanio: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${articulo.calificaciones} calificaciones',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    articulo.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto agregado al carrito'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Añadir al carrito',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}