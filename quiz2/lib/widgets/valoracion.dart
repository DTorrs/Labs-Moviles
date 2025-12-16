import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Valoracion extends StatelessWidget {
  final double valoracion;
  final double tamanio;
  
  const Valoracion({
    Key? key, 
    required this.valoracion,
    this.tamanio = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: valoracion,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: tamanio,
      direction: Axis.horizontal,
    );
  }
}