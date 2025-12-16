import 'package:flutter/material.dart';
import 'screens/menu_principal.dart';
import 'screens/lista_articulos.dart';
import 'screens/lista_ofertas.dart';
import 'screens/ficha_articulo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Artículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/lista_articulos': (context) => const ListaArticulos(),
        '/lista_ofertas': (context) => const ListaOfertas(),
        '/ficha_articulo': (context) => const FichaArticulo(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuPrincipal(
      onArticulosPressed: () {
        Navigator.pushNamed(context, '/lista_articulos');
      },
      onOfertasPressed: () {
        Navigator.pushNamed(context, '/lista_ofertas');
      },
    );
  }
}