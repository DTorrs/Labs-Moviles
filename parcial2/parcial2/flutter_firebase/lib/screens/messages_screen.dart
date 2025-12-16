import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../models/message_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar mensajes al iniciar
    Future.microtask(() {
      Provider.of<MessageProvider>(context, listen: false).loadReceivedMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (messageProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${messageProvider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    messageProvider.loadReceivedMessages();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        if (messageProvider.messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes mensajes',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Los mensajes que recibas aparecerán aquí',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => messageProvider.loadReceivedMessages(),
          child: ListView.builder(
            itemCount: messageProvider.messages.length,
            itemBuilder: (context, index) {
              final message = messageProvider.messages[index];
              return MessageListItem(message: message);
            },
          ),
        );
      },
    );
  }
}

class MessageListItem extends StatelessWidget {
  final Message message;
  
  const MessageListItem({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL base para imágenes
    final baseUrl = 'http://10.0.2.2:3000'; // Cambiar según tu configuración
    final hasPhoto = message.senderPhoto != null && message.senderPhoto!.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: remitente y fecha
            Row(
              children: [
                // Foto del remitente
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  backgroundImage: hasPhoto
                      ? NetworkImage('$baseUrl${message.senderPhoto}')
                      : null,
                  child: !hasPhoto
                      ? Text(message.senderName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Información del remitente y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message.formattedDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Título del mensaje
            Text(
              message.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            
            // Cuerpo del mensaje
            Text(
              message.body,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}