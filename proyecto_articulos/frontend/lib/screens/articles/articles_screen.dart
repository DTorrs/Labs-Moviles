import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../widgets/article_item.dart';
import '../base/base_screen.dart';
import '../base/app_router.dart';

class ArticlesScreen extends BaseScreen {
  const ArticlesScreen({Key? key, Map<String, dynamic>? params}) : super(key: key, params: params);

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends BaseScreenState<ArticlesScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar artículos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔍 Cargando artículos después del primer frame');
      Provider.of<ArticleProvider>(context, listen: false).loadArticles();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // Para detectar cuando la pantalla vuelve a ser visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sincronizar favoritos cada vez que cambia el contexto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<ArticleProvider>(context, listen: false);
        provider.refreshFavoriteStatus();
      }
    });
  }
  
  // Este método nos avisa cuando la app cambia de estado (pausa, reanudación, etc)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // La app vuelve a estar en primer plano
      debugPrint('🔍 App resumed, refreshing favorites');
      Provider.of<ArticleProvider>(context, listen: false).refreshFavoriteStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extracción de parámetros
    final String title = widget.params?['title'] ?? 'Artículos';
    final bool showRefreshButton = widget.params?['showRefreshButton'] ?? true;
    final bool showLogoutButton = widget.params?['showLogoutButton'] ?? true;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (showRefreshButton)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                debugPrint('🔍 Recargando artículos manualmente');
                Provider.of<ArticleProvider>(context, listen: false).loadArticles();
              },
            ),
          if (showLogoutButton)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(),
            ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          debugPrint('🔍 Estado del provider: isLoading=${provider.isLoading}, artículos=${provider.articles.length}');
          
          if (provider.isLoading) {
            return buildLoadingIndicator(message: 'Cargando artículos...');
          }

          if (provider.articles.isEmpty) {
            return buildEmptyState(
              icon: Icons.shopping_bag,
              title: 'No hay artículos disponibles',
              subtitle: provider.lastError.isNotEmpty 
                ? 'Error: ${provider.lastError}'
                : 'Intente actualizar más tarde',
              buttonText: 'Actualizar',
              onButtonPressed: () => provider.loadArticles(),
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

              // Lista de artículos
              Expanded(
                child: provider.viewMode == ViewMode.list
                    ? ListView.builder(
                        itemCount: provider.articles.length,
                        itemBuilder: (context, index) {
                          final article = provider.articles[index];
                          return ArticleItem(
                            article: article,
                            viewMode: provider.viewMode,
                          );
                        },
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: provider.articles.length,
                        itemBuilder: (context, index) {
                          final article = provider.articles[index];
                          return ArticleItem(
                            article: article,
                            viewMode: provider.viewMode,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Navegar a favoritos
            AppRouter.navigateToFavorites(context);
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Artículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}