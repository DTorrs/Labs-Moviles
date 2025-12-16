class User {
  final int id;
  final String username;
  final String email;
  final DateTime? lastLogin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.lastLogin,
    required this.createdAt,
  });

  // Constructor defecto para manejar casos extremos
  User.defaultUser()
      : id = 0,
        username = 'Usuario',
        email = 'usuario@example.com',
        lastLogin = null,
        createdAt = DateTime.now();

  // Método fromJson ultra-resistente
  factory User.fromJson(Map<String, dynamic>? json) {
    // Si json es null, retornar un usuario por defecto
    if (json == null) {
      return User.defaultUser();
    }

    // Intentar extraer valores con manejo seguro de tipos
    try {
      final int id = json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

      final String username = json['username']?.toString() ?? '';
      final String email = json['email']?.toString() ?? '';

      DateTime? lastLogin;
      if (json['last_login'] != null) {
        try {
          lastLogin = DateTime.tryParse(json['last_login'].toString());
        } catch (_) {
          lastLogin = null;
        }
      }

      DateTime createdAt;
      if (json['created_at'] != null) {
        try {
          createdAt = DateTime.tryParse(json['created_at'].toString()) ??
              DateTime.now();
        } catch (_) {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }

      return User(
        id: id,
        username: username,
        email: email,
        lastLogin: lastLogin,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error al parsear usuario: $e');
      return User.defaultUser();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, lastLogin: $lastLogin, createdAt: $createdAt}';
  }
}