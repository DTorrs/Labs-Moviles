class User {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? photoUrl;

  User({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}