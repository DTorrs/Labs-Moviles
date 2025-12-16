import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/message_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_profile_screen.dart';

// GlobalKey para el navegador que usará FirebaseService
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar el estado de autenticación
    Future.microtask(() {
      Provider.of<AuthProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  // Inicializar notificaciones y obtener token FCM
  final firebaseService = FirebaseService(navigatorKey: navigatorKey);
  await firebaseService.initializeNotifications();
  
  runApp(MyApp(firebaseService: firebaseService));
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;
  
  const MyApp({Key? key, required this.firebaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        Provider<FirebaseService>.value(value: firebaseService),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,  // Importante: usa la misma clave aquí
        title: 'Firebase Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/user-profile': (context) => const UserProfileScreen(),
        },
      ),
    );
  }
}