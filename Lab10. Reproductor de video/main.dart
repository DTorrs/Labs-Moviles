import 'package:flutter/material.dart';
import 'video_list_screen.dart';
import 'video_player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const VideoListScreen(),
        '/player': (context) => const VideoPlayerScreen(),
      },
    );
  }
}