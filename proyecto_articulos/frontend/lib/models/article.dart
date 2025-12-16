class Article {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String seller;
  final double rating;
  final double price;
  final DateTime createdAt;
  final int? favoriteId; // ID de favorito si está en favoritos

  Article({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.seller,
    required this.rating,
    required this.price,
    required this.createdAt,
    this.favoriteId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      seller: json['seller'],
      rating: json['rating']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      favoriteId: json['favoriteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'seller': seller,
      'rating': rating,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'favoriteId': favoriteId,
    };
  }

  // Para SQLite (base de datos local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'seller': seller,
      'rating': rating,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      seller: map['seller'],
      rating: map['rating'],
      price: map['price'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Crear una copia con cambios
  Article copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? seller,
    double? rating,
    double? price,
    DateTime? createdAt,
    int? favoriteId,
  }) {
    return Article(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      seller: seller ?? this.seller,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      favoriteId: favoriteId ?? this.favoriteId,
    );
  }
}