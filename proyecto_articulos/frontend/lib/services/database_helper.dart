import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/article.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'articulos_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Tabla de artículos favoritos
    await db.execute('''
      CREATE TABLE favorite_articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        seller TEXT NOT NULL,
        rating REAL NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Eliminar la base de datos
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'articulos_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Insertar artículo favorito
  Future<int> insertFavoriteArticle(Article article) async {
    final db = await database;
    
    // Verificar si ya existe
    final List<Map<String, dynamic>> existingArticles = await db.query(
      'favorite_articles',
      where: 'article_id = ?',
      whereArgs: [article.id],
    );
    
    if (existingArticles.isNotEmpty) {
      return existingArticles.first['id'];
    }
    
    // Insertar
    return await db.insert(
      'favorite_articles',
      {
        'article_id': article.id,
        'name': article.name,
        'description': article.description,
        'image_url': article.imageUrl,
        'seller': article.seller,
        'rating': article.rating,
        'price': article.price,
        'created_at': article.createdAt.toIso8601String(),
      },
    );
  }

  // Eliminar artículo favorito
  Future<int> deleteFavoriteArticle(int articleId) async {
    final db = await database;
    return await db.delete(
      'favorite_articles',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }

  // Obtener todos los artículos favoritos
  Future<List<Article>> getFavoriteArticles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_articles');
    
    return List.generate(maps.length, (i) {
      return Article(
        id: maps[i]['article_id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        imageUrl: maps[i]['image_url'],
        seller: maps[i]['seller'],
        rating: maps[i]['rating'],
        price: maps[i]['price'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        favoriteId: maps[i]['id'],
      );
    });
  }

  // Verificar si un artículo está en favoritos
  Future<bool> isArticleFavorite(int articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'favorite_articles',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
    
    return result.isNotEmpty;
  }
  
}