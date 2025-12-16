import 'package:flutter/material.dart';
import 'video_info.dart';
import 'item_usuario.dart';

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista de videos con URLs que funcionan
    final List<VideoInfo> videos = [
      VideoInfo(
        nombre: "Abeja en flor",
        url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        thumbnailUrl: "https://images.pexels.com/photos/2114014/pexels-photo-2114014.jpeg",
      ),
      VideoInfo(
        nombre: "Conejo",
        url: "https://www.w3schools.com/html/mov_bbb.mp4",
        thumbnailUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/800px-Big_buck_bunny_poster_big.jpg",
      ),
      VideoInfo(
        nombre: "Mariposa",
        url: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        thumbnailUrl: "https://images.pexels.com/photos/2260815/pexels-photo-2260815.jpeg",
      ),
      VideoInfo(
        nombre: "Abeja de nuevo",
        url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        thumbnailUrl: "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492_640.jpg",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproductor de Videos'),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ItemUsuario(videoInfo: videos[index]);
        },
      ),
    );
  }
}