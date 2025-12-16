import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/article_provider.dart';

class ArticleItem extends StatefulWidget {
  final Article article;
  final bool isFavorite;
  final ViewMode viewMode;

  const ArticleItem({
    Key? key,
    required this.article,
    this.isFavorite = false,
    required this.viewMode,
  }) : super(key: key);

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  bool _isLoading = false;
  late bool _isFavorite;
  
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.article.favoriteId != null;
    debugPrint('♥️ Inicializando ArticleItem: ${widget.article.id} - ${widget.article.name}');
    debugPrint('♥️ Estado inicial: _isFavorite=$_isFavorite');
    
    // Verificar estado actual desde el provider para asegurar sincronización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
        final currentFavoriteStatus = articleProvider.favoriteArticles
            .any((a) => a.id == widget.article.id);
            
        // Solo actualizar si hay diferencia con nuestro estado local
        if (_isFavorite != currentFavoriteStatus) {
          debugPrint('♥️ Corrigiendo estado de favorito: $_isFavorite -> $currentFavoriteStatus');
          setState(() {
            _isFavorite = currentFavoriteStatus;
          });
        }
      }
    });
  }
  
  @override
  void didUpdateWidget(ArticleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Actualizar estado si cambia desde fuera
    if (oldWidget.article.favoriteId != widget.article.favoriteId) {
      setState(() {
        _isFavorite = widget.article.favoriteId != null;
      });
      debugPrint('♥️ Actualizando estado: _isFavorite=$_isFavorite');
    }
  }
  
  // Verificar el estado actual siempre que el widget vuelva a ser visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Verificar estado actual desde el provider
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    final currentFavoriteStatus = articleProvider.favoriteArticles
        .any((a) => a.id == widget.article.id);
        
    // Solo actualizar si hay diferencia con nuestro estado local
    if (_isFavorite != currentFavoriteStatus && mounted) {
      debugPrint('♥️ Sincronizando estado de favorito: $_isFavorite -> $currentFavoriteStatus');
      setState(() {
        _isFavorite = currentFavoriteStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar estado actual desde el provider para mantener sincronización
    final articleProvider = Provider.of<ArticleProvider>(context);
    final isFavoriteInProvider = articleProvider.favoriteArticles.any((a) => a.id == widget.article.id);
    
    // Si hay discrepancia, actualizar nuestro estado local
    if (_isFavorite != isFavoriteInProvider) {
      debugPrint('♥️ Corrigiendo estado en build: $_isFavorite -> $isFavoriteInProvider');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isFavorite = isFavoriteInProvider;
          });
        }
      });
    }
    
    return widget.viewMode == ViewMode.list
        ? _buildListItem(context)
        : _buildGridItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImage(),
              ),
            ),
            const SizedBox(width: 12),
            
            // Información del artículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.article.seller,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: widget.article.rating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 16,
                        ignoreGestures: true,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (_) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.article.rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón de favorito
            _buildFavoriteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 120,
                  child: _buildImage(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildFavoriteButton(inGrid: true),
              ),
            ],
          ),
          
          // Información del artículo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.article.seller,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: widget.article.rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 14,
                      ignoreGestures: true,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (_) {},
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.article.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (widget.article.imageUrl == null || widget.article.imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.article.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.error,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoriteButton({bool inGrid = false}) {
    // Diferente estilo dependiendo de si está en grid o lista
    if (inGrid) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _buildFavoriteIconButton(),
      );
    } else {
      return _buildFavoriteIconButton();
    }
  }
  
  Widget _buildFavoriteIconButton() {
    return _isLoading 
      ? const SizedBox(
          width: 24, 
          height: 24, 
          child: CircularProgressIndicator(
            strokeWidth: 2, 
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          )
        )
      : IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: _isFavorite ? Colors.amber : null,
            size: 28,
          ),
        );
  }
  
  Future<void> _toggleFavorite() async {
    if (_isLoading) return;
    
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      debugPrint('♥️ Toggling favorite for article ${widget.article.id}');
      debugPrint('♥️ Estado antes del toggle: _isFavorite=$_isFavorite');
      
      // Forzar el estado contrario al actual
      bool success;
      if (_isFavorite) {
        success = await articleProvider.removeFromFavorites(widget.article);
      } else {
        success = await articleProvider.addToFavorites(widget.article);
      }
      
      if (success) {
        debugPrint('♥️ Favorite toggled successfully');
        // Invertir el estado MANUALMENTE
        setState(() {
          _isFavorite = !_isFavorite;
        });
        debugPrint('♥️ Nuevo estado después del toggle: _isFavorite=$_isFavorite');
        
        // Forzar sincronización de listas
        articleProvider.refreshFavoriteStatus();
        
        // Mostrar snackbar con acción realizada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFavorite
                    ? 'Artículo añadido a favoritos'
                    : 'Artículo eliminado de favoritos',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        debugPrint('♥️ Failed to toggle favorite');
        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar favoritos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('♥️ Error toggling favorite: $e');
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}