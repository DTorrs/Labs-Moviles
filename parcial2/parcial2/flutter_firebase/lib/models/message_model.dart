import 'package:intl/intl.dart';

class Message {
  final int id;
  final String title;
  final String body;
  final String senderEmail;
  final String senderName;
  final String? senderPhoto;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.title,
    required this.body,
    required this.senderEmail,
    required this.senderName,
    this.senderPhoto,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      senderEmail: json['senderEmail'],
      senderName: json['senderName'] ?? 'Usuario',
      senderPhoto: json['senderPhoto'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get formattedDate {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt);
  }
}