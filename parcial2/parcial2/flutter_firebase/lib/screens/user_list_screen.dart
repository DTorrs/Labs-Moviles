import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../models/user_model.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar lista de usuarios al iniciar
    Future.microtask(() {
      Provider.of<MessageProvider>(context, listen: false).loadUsers();
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
                    messageProvider.loadUsers();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        if (messageProvider.users.isEmpty) {
          return const Center(
            child: Text('No hay usuarios disponibles'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => messageProvider.loadUsers(),
          child: ListView.builder(
            itemCount: messageProvider.users.length,
            itemBuilder: (context, index) {
              final user = messageProvider.users[index];
              return UserListItem(user: user);
            },
          ),
        );
      },
    );
  }
}

class UserListItem extends StatelessWidget {
  final User user;
  
  const UserListItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL base para imágenes
    final baseUrl = 'http://10.0.2.2:3000'; // Cambiar según tu configuración
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: hasPhoto
              ? NetworkImage('$baseUrl${user.photoUrl}')
              : null,
          child: !hasPhoto
              ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
              : null,
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar al perfil del usuario
          Navigator.of(context).pushNamed(
            '/user-profile',
            arguments: user.email,
          );
        },
      ),
    );
  }
}