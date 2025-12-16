import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../models/user_model.dart';
import 'send_message_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener el email del usuario a mostrar
    final email = ModalRoute.of(context)!.settings.arguments as String;
    
    // Cargar datos del usuario
    Future.microtask(() {
      Provider.of<MessageProvider>(context, listen: false).loadUserProfile(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Consumer<MessageProvider>(
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
                      final email = ModalRoute.of(context)!.settings.arguments as String;
                      messageProvider.loadUserProfile(email);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          if (messageProvider.selectedUser == null) {
            return const Center(
              child: Text('Usuario no encontrado'),
            );
          }
          
          final user = messageProvider.selectedUser!;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto de perfil
                _buildProfileImage(user),
                const SizedBox(height: 24),
                
                // Nombre completo
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Cargo
                Text(
                  user.role,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Información de contacto
                _buildInfoItem(Icons.email, 'Correo electrónico', user.email),
                const Divider(),
                _buildInfoItem(Icons.phone, 'Número telefónico', user.phoneNumber),
                
                const Spacer(),
                
                // Botón para enviar mensaje
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SendMessageScreen(receiver: user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('ENVIAR MENSAJE'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileImage(User user) {
    // URL base para imágenes
    final baseUrl = 'http://10.0.2.2:3000'; // Cambiar según tu configuración
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    
    return CircleAvatar(
      radius: 64,
      backgroundColor: Colors.blue,
      backgroundImage: hasPhoto
          ? NetworkImage('$baseUrl${user.photoUrl}')
          : null,
      child: !hasPhoto
          ? Text(
              user.fullName[0].toUpperCase(),
              style: const TextStyle(fontSize: 48, color: Colors.white),
            )
          : null,
    );
  }
  
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}