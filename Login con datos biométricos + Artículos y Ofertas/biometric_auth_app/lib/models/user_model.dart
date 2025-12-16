class User {
  final int id;
  final String username;
  final bool biometricEnabled;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.biometricEnabled,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      biometricEnabled: json['biometricEnabled'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'biometricEnabled': biometricEnabled,
      'token': token,
    };
  }

  User copyWith({
    int? id,
    String? username,
    bool? biometricEnabled,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      token: token ?? this.token,
    );
  }
}