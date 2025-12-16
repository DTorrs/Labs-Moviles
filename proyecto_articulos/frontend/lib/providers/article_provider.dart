import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

enum ViewMode {
  list,
  grid,
}

class ArticleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Article> _articles = [];
  List<Article> _favoriteArticles = [];
  bool _isLoading = false;
  ViewMode _viewMode = ViewMode.list;
  String _lastError = '';
  
  List<Article> get articles => _articles;
  List<Article> get favoriteArticles => _favoriteArticles;
  bool get isLoading => _isLoading;
  ViewMode get viewMode => _viewMode;
  String get lastError => _lastError;
  
  // Constructor
  ArticleProvider() {
    debugPrint('⭐ ArticleProvider inicializado');
    loadArticles();
    loadFavoriteArticles();
  }
  
  // Nuevo método para resetear el estado de favoritos en memoria
  void resetFavorites() {
    debugPrint('⭐ Reseteando estado de favoritos en ArticleProvider');
    // Limpiar favoriteId de todos los artículos en memoria
    if (_articles.isNotEmpty) {
      _articles = _articles.map((article) => article.copyWith(favoriteId: null)).toList();
    }
    // Limpiar lista de favoritos
    _favoriteArticles = [];
    notifyListeners();
  }
  
  // Cambiar modo de visualización
  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
    notifyListeners();
  }
  
  // Método público para sincronizar estado de favoritos
  Future<void> refreshFavoriteStatus() async {
    await _markFavoritesInArticlesList();
    notifyListeners();
  }
  
  // Cargar artículos
  Future<void> loadArticles() async {
    _isLoading = true;
    _lastError = '';
    notifyListeners();
    
    try {
      debugPrint('⭐ Intentando cargar artículos...');
      
      // Intentamos obtener artículos del API
      final apiArticles = await _apiService.getArticles();
      
      debugPrint('⭐ Artículos recibidos: ${apiArticles.length}');
      
      if (apiArticles.isEmpty) {
        // Si no hay artículos, creamos algunos de prueba
        debugPrint('⭐ No hay artículos, creando datos de ejemplo');
        _articles = _createDummyArticles();
      } else {
        _articles = apiArticles;
      }
      
      // Marcar favoritos
      await _markFavoritesInArticlesList();
      
    } catch (e) {
      _lastError = e.toString();
      debugPrint('⭐ Error al cargar artículos: $e');
      // En caso de error, crear datos de ejemplo
      _articles = _createDummyArticles();
      
      // Intentar marcar favoritos aún así
      await _markFavoritesInArticlesList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método auxiliar para actualizar favoritos en la lista principal
  Future<void> _markFavoritesInArticlesList() async {
    try {
      // Cargar IDs de favoritos desde SQLite
      final favoriteArticles = await _dbHelper.getFavoriteArticles();
      final favoriteIds = favoriteArticles.map((a) => a.id).toSet();
      
      debugPrint('⭐ IDs de favoritos desde SQLite: $favoriteIds');
      
      // Actualizar todos los artículos con su estado de favorito
      for (var i = 0; i < _articles.length; i++) {
        final isFavorite = favoriteIds.contains(_articles[i].id);
        if (isFavorite) {
          // Encontrar el favoriteId correspondiente en la lista de favoritos
          final favoriteArticle = favoriteArticles.firstWhere(
            (a) => a.id == _articles[i].id,
            orElse: () => _articles[i],
          );
          
          _articles[i] = _articles[i].copyWith(
            favoriteId: favoriteArticle.favoriteId ?? 1
          );
          debugPrint('⭐ Marcando artículo ${_articles[i].id} como favorito');
        } else {
          _articles[i] = _articles[i].copyWith(favoriteId: null);
        }
      }
    } catch (e) {
      debugPrint('⭐ Error al marcar favoritos: $e');
    }
  }
  
  // Crear artículos de prueba (solo si fallan todas las opciones)
  List<Article> _createDummyArticles() {
    debugPrint('⭐ Creando artículos de prueba');
    return [
      Article(
        id: 1,
        name: 'Smartphone Galaxy S23',
        description: 'Smartphone de última generación con cámara de alta resolución.',
        imageUrl: 'https://via.placeholder.com/300',
        seller: 'Electrónica TechStore',
        rating: 4.7,
        price: 999.99,
        createdAt: DateTime.now(),
      ),
      Article(
        id: 2,
        name: 'Laptop Ultradelgada',
        description: 'Laptop potente y ligera para trabajo y entretenimiento.',
        imageUrl: 'https://via.placeholder.com/300',
        seller: 'PC & Accesorios',
        rating: 4.5,
        price: 1299.99,
        createdAt: DateTime.now(),
      ),
      Article(
        id: 3,
        name: 'Audífonos Inalámbricos',
        description: 'Audífonos con cancelación de ruido y conexión Bluetooth.',
        imageUrl: 'https://via.placeholder.com/300',
        seller: 'Audio Premium',
        rating: 4.8,
        price: 199.99,
        createdAt: DateTime.now(),
      ),
      Article(
        id: 4,
        name: 'Smartwatch Deportivo',
        description: 'Reloj inteligente con monitor de ritmo cardíaco y GPS.',
        imageUrl: 'https://via.placeholder.com/300',
        seller: 'Deportes Xtreme',
        rating: 4.2,
        price: 249.99,
        createdAt: DateTime.now(),
      ),
    ];
  }
  
  // Cargar artículos favoritos
  Future<void> loadFavoriteArticles() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('⭐ Cargando artículos favoritos desde SQLite');
      // Obtener favoritos de la base de datos local
      _favoriteArticles = await _dbHelper.getFavoriteArticles();
      debugPrint('⭐ Favoritos cargados: ${_favoriteArticles.length}');
      
      // Asegurar sincronización con la lista principal
      await _markFavoritesInArticlesList();
    } catch (e) {
      debugPrint('⭐ Error al cargar favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Agregar a favoritos
  Future<bool> addToFavorites(Article article) async {
    try {
      debugPrint('⭐ Agregando a favoritos: ${article.id} - ${article.name}');
      
      // Primero intentamos agregar a la API
      final response = await _apiService.addToFavorites(article.id);
      debugPrint('⭐ Respuesta de la API: $response');
      
      if (response['success'] == true) {
        // Si se agregó correctamente en la API, agregar a SQLite
        final localId = await _dbHelper.insertFavoriteArticle(article);
        debugPrint('⭐ Artículo agregado a SQLite con ID: $localId');
        
        // Crear una nueva instancia del artículo con favoriteId
        final updatedArticle = article.copyWith(favoriteId: localId);
        
        // Actualizar en la lista de artículos
        final index = _articles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          _articles[index] = updatedArticle;
        }
        
        // Verificar si ya existe en favoritos
        final favoriteIndex = _favoriteArticles.indexWhere((a) => a.id == article.id);
        if (favoriteIndex == -1) {
          // Añadir a favoritos si no existe
          _favoriteArticles.add(updatedArticle);
        }
        
        // Sincronizar listas
        await _markFavoritesInArticlesList();
        
        notifyListeners();
        return true;
      } else {
        debugPrint('⭐ Error al agregar favorito en API: ${response['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('⭐ Error en addToFavorites: $e');
      return false;
    }
  }
  
  // Eliminar de favoritos
  Future<bool> removeFromFavorites(Article article) async {
    try {
      debugPrint('⭐ Eliminando de favoritos: ${article.id} - ${article.name}');
      
      // Primero intentamos eliminar de la API
      final success = await _apiService.removeFromFavorites(article.id);
      debugPrint('⭐ Respuesta de la API para eliminar: $success');
      
      // Independientemente de la respuesta API, eliminamos de SQLite
      await _dbHelper.deleteFavoriteArticle(article.id);
      debugPrint('⭐ Artículo eliminado de SQLite');
      
      // Crear una nueva instancia del artículo sin favoriteId
      final updatedArticle = article.copyWith(favoriteId: null);
      
      // Actualizar lista de artículos
      final index = _articles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        _articles[index] = updatedArticle;
      }
      
      // Eliminar de la lista de favoritos
      _favoriteArticles.removeWhere((a) => a.id == article.id);
      
      // Sincronizar listas para asegurar coherencia
      await _markFavoritesInArticlesList();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('⭐ Error en removeFromFavorites: $e');
      // Incluso en caso de error, intentamos actualizar la UI
      try {
        // Actualizar lista de artículos
        final index = _articles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          _articles[index] = article.copyWith(favoriteId: null);
        }
        
        // Eliminar de la lista de favoritos
        _favoriteArticles.removeWhere((a) => a.id == article.id);
        
        // Sincronizar listas
        await _markFavoritesInArticlesList();
        
        notifyListeners();
      } catch (innerError) {
        debugPrint('⭐ Error adicional: $innerError');
      }
      return true; // Devolvemos true para que la UI se actualice
    }
  }
  
  // Alternar favorito
  Future<bool> toggleFavorite(Article article) async {
    debugPrint('⭐ Alternando favorito para: ${article.id} - ${article.name}');
    debugPrint('⭐ Estado actual: favoriteId=${article.favoriteId}');
    
    try {
      if (article.favoriteId != null) {
        // Es favorito, lo eliminamos
        return await removeFromFavorites(article);
      } else {
        // No es favorito, lo agregamos
        return await addToFavorites(article);
      }
    } catch (e) {
      debugPrint('⭐ Error en toggleFavorite: $e');
      return false;
    }
  }
}