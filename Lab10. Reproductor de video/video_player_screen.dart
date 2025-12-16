import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'video_info.dart';
import 'info_video_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late VideoInfo videoInfo;
  
  // Variables para almacenar información del video calculada dinámicamente
  Duration _duration = Duration.zero;
  String _fileSize = "Calculando...";
  bool _isLoadingSize = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener argumentos de la ruta
    videoInfo = ModalRoute.of(context)!.settings.arguments as VideoInfo;
    
    // Inicializar el controlador de video
    _controller = VideoPlayerController.network(videoInfo.url)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _duration = _controller.value.duration;
          // Reproducir automáticamente al cargar
          _controller.play();
        });
        
        // Obtener el tamaño real del archivo
        _getFileSize(videoInfo.url);
      });
  }
  
  // Obtener el tamaño real del archivo mediante una solicitud HEAD
  Future<void> _getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final sizeInBytes = int.parse(contentLength);
          final sizeInMB = sizeInBytes / (1024 * 1024);
          
          setState(() {
            _fileSize = "${sizeInMB.toStringAsFixed(1)} MB";
            _isLoadingSize = false;
          });
          return;
        }
      }
      
      // Si no se puede obtener el tamaño, hacer una estimación
      _estimateFileSize();
    } catch (e) {
      print("Error al obtener el tamaño del archivo: $e");
      _estimateFileSize();
    }
  }
  
  // Estimar el tamaño del archivo basado en la duración
  void _estimateFileSize() {
    // Estimamos ~1.5MB por minuto para un video de calidad media
    double minutes = _duration.inSeconds / 60;
    double estimatedSize = minutes * 1.5;
    
    setState(() {
      _fileSize = "${estimatedSize.toStringAsFixed(1)} MB (estimado)";
      _isLoadingSize = false;
    });
  }

  // Formatear la duración en formato mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(videoInfo.nombre),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video en recuadro fijo
            if (_isInitialized)
              Container(
                height: 200,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Container(
                height: 200,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.black,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            
            // Controles de reproducción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.replay,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.seekTo(Duration.zero);
                        _controller.play();
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Información del video usando el widget InfoVideoWidget con datos extraídos realmente
            InfoVideoWidget(
              nombre: videoInfo.nombre,
              duracion: _formatDuration(_duration),
              tamano: _isLoadingSize ? "Calculando..." : _fileSize,
            ),
          ],
        ),
      ),
    );
  }
}