import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Agregar una propiedad opcional para el navigatorKey
  final GlobalKey<NavigatorState>? navigatorKey;
  
  // Hacer el parámetro opcional
  FirebaseService({this.navigatorKey});
  
  // Solicitar permisos y configurar notificaciones
  Future<String?> initializeNotifications() async {
    // Solicitar permisos para notificaciones
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    
    // Configurar manejadores de notificaciones
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Obtener token FCM
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');
    
    return fcmToken;
  }
  
  // Manejar mensaje recibido en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.notification?.title}');
    
    // Mostrar un simple diálogo en lugar de una notificación local
    if (message.notification != null && navigatorKey != null) {
      final context = navigatorKey!.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? 'Nuevo mensaje'),
            content: Text(message.notification!.body ?? ''),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Ver'),
                onPressed: () {
                  Navigator.pop(context);
                  // Navegar a la pantalla de mensajes
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          ),
        );
      }
    }
  }
  
  // Manejar mensaje abierto desde segundo plano
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Mensaje abierto desde segundo plano: ${message.notification?.title}');
    // Navegar a la pantalla de mensajes automáticamente
    navigatorKey?.currentState?.pushNamed('/home');
  }
  
  // Obtener el token actual
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
  
  // Eliminar token al cerrar sesión
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
  }
}