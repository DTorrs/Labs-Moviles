import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'video_info.dart';

class ItemUsuario extends StatefulWidget {
  final VideoInfo videoInfo;

  const ItemUsuario({Key? key, required this.videoInfo}) : super(key: key);

  @override
  _ItemUsuarioState createState() => _ItemUsuarioState();
}

class _ItemUsuarioState extends State<ItemUsuario> {
  String _duracion = "Calculando...";
  String _tamano = "Calculando...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarInfoVideo();
  }

  // Cargar información del video para mostrarla en la lista
  Future<void> _cargarInfoVideo() async {
    try {
      // Obtener el tamaño del archivo
      await _getFileSize(widget.videoInfo.url);
      
      // Para obtener la duración, necesitaríamos cargar el video
      final controller = VideoPlayerController.network(widget.videoInfo.url);
      await controller.initialize();
      
      if (mounted) {
        setState(() {
          _duracion = _formatDuration(controller.value.duration);
          _isLoading = false;
        });
      }
      
      // Liberar recursos
      controller.dispose();
    } catch (e) {
      print("Error cargando info del video: $e");
      if (mounted) {
        setState(() {
          _duracion = "00:10";
          _tamano = "1.2 MB";
          _isLoading = false;
        });
      }
    }
  }
  
  // Obtener el tamaño del archivo
  Future<void> _getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final sizeInBytes = int.parse(contentLength);
          final sizeInMB = sizeInBytes / (1024 * 1024);
          
          if (mounted) {
            setState(() {
              _tamano = "${sizeInMB.toStringAsFixed(1)} MB";
            });
          }
          return;
        }
      }
      
      // Si no se puede obtener, usar valor predeterminado
      if (mounted) {
        setState(() {
          _tamano = "1.2 MB";
        });
      }
    } catch (e) {
      print("Error al obtener el tamaño: $e");
      if (mounted) {
        setState(() {
          _tamano = "1.2 MB";
        });
      }
    }
  }
  
  // Formatear duración
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/player',
                arguments: widget.videoInfo,
              );
            },
            child: Row(
              children: [
                // Thumbnail real del video
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.videoInfo.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.videoInfo.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Mostrar duración y tamaño en la lista
                      _isLoading
                          ? const Text("Cargando información...")
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tiempo: $_duracion"),
                                Text("Tamaño: $_tamano"),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}