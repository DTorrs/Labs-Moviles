import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../widgets/article_item.dart';
import '../base/base_screen.dart';
import '../base/app_router.dart';

class FavoritesScreen extends BaseScreen {
  const FavoritesScreen({Key? key, Map<String, dynamic>? params}) : super(key: key, params: params);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends BaseScreenState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💙 FavoritesScreen inicializada');
    // Cargar favoritos al iniciar
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    showLoadingIndicator();

    debugPrint('💙 Cargando artículos favoritos');
    try {
      await Provider.of<ArticleProvider>(context, listen: false).loadFavoriteArticles();
    } catch (e) {
      debugPrint('💙 Error al cargar favoritos: $e');
      setErrorMessage('Error al cargar favoritos: ${e.toString()}');
    } finally {
      hideLoadingIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraer parámetros o usar valores predeterminados
    final String title = widget.params?['title'] ?? 'Mis Favoritos';
    final bool showRefreshButton = widget.params?['showRefreshButton'] ?? true;
    final IconData emptyIcon = widget.params?['emptyIcon'] ?? Icons.star_border;
    
    debugPrint('💙 Construyendo FavoritesScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Botón para recargar favoritos (opcional mediante parámetro)
          if (showRefreshButton)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFavorites,
              tooltip: 'Recargar favoritos',
            ),
        ],
      ),
      body: isLoading 
          ? buildLoadingIndicator(message: 'Cargando favoritos...')
          : Consumer<ArticleProvider>(
              builder: (context, provider, child) {
                debugPrint('💙 Favoritos: ${provider.favoriteArticles.length}');
                
                if (provider.favoriteArticles.isEmpty) {
                  return buildEmptyState(
                    icon: emptyIcon,
                    title: 'No tienes artículos favoritos',
                    subtitle: 'Agrega artículos a favoritos para verlos aquí',
                    buttonText: 'Explorar Artículos',
                    onButtonPressed: () => AppRouter.navigateToArticles(context),
                  );
                }

                return Column(
                  children: [
                    // Botón para cambiar modo de visualización
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => provider.toggleViewMode(),
                            icon: Icon(
                              provider.viewMode == ViewMode.list
                                  ? Icons.grid_view
                                  : Icons.view_list,
                            ),
                            tooltip: 'Cambiar vista',
                          ),
                        ],
                      ),
                    ),

                    // Lista de favoritos
                    Expanded(
                      child: provider.viewMode == ViewMode.list
                          ? ListView.builder(
                              itemCount: provider.favoriteArticles.length,
                              itemBuilder: (context, index) {
                                final article = provider.favoriteArticles[index];
                                debugPrint('💙 Renderizando favorito: ${article.name}');
                                return ArticleItem(
                                  article: article,
                                  isFavorite: true,
                                  viewMode: provider.viewMode,
                                );
                              },
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: provider.favoriteArticles.length,
                              itemBuilder: (context, index) {
                                final article = provider.favoriteArticles[index];
                                return ArticleItem(
                                  article: article,
                                  isFavorite: true,
                                  viewMode: provider.viewMode,
                                );
                              },
                            ),
                    ),
                    
                    // Si hay un mensaje de error, mostrarlo al final
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: buildErrorMessage(),
                      ),
                  ],
                );
              },
            ),
    );
  }
}