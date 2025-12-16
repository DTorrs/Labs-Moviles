import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/articulo.dart';
import 'valoracion.dart';

class ItemArticulo extends StatelessWidget {
  final Articulo articulo;
  final Function() onTap;

  const ItemArticulo({
    Key? key,
    required this.articulo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double valoracionDouble = articulo.getValoracionCorregida(); // Convertir a escala 0-5
    final bool tieneDescuento = articulo.tieneDescuento();
    final double precioFinal = articulo.getPrecioConDescuento();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: articulo.urlimagen,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Nombre del artículo
                    Text(
                      articulo.articulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // 3. Precio
                    Row(
                      children: [
                        Text(
                          '\$${precioFinal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        // 4. Porcentaje de descuento (si aplica)
                        if (tieneDescuento)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${articulo.descuento}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 5. Widget Valoracion
                    Valoracion(valoracion: valoracionDouble),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}