class Articulo {
  final String articulo;
  final String precio;
  final String descuento;
  final String urlimagen;
  final String valoracion;
  final String calificaciones;
  final String descripcion;

  Articulo({
    required this.articulo,
    required this.precio,
    required this.descuento,
    required this.urlimagen,
    required this.valoracion,
    required this.calificaciones,
    required this.descripcion,
  });
  
  // Obtener valoración corregida (escala 0-5)
  double getValoracionCorregida() {
    return double.parse(valoracion) / 10;
  }

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      articulo: json['articulo'] ?? '',
      precio: json['precio'] ?? '',
      descuento: json['descuento'] ?? '0',
      urlimagen: json['urlimagen'] ?? '',
      valoracion: json['valoracion'] ?? '0',
      calificaciones: json['calificaciones'] ?? '0',
      descripcion: json['descripcion'] ?? '',
    );
  }

  // Método para obtener el precio con descuento aplicado
  double getPrecioConDescuento() {
    double precioBase = double.parse(precio);
    double descuentoValor = double.parse(descuento);
    
    if (descuentoValor <= 0) {
      return precioBase;
    }
    
    return precioBase * (1 - (descuentoValor / 100));
  }

  // Método para verificar si tiene descuento
  bool tieneDescuento() {
    return double.parse(descuento) > 0;
  }
}