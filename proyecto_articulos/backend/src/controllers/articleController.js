const Article = require('../models/Article');
const Favorite = require('../models/Favorite');

// Obtener todos los artículos
exports.getAllArticles = async (req, res) => {
  try {
    const articles = await Article.findAll();
    
    res.status(200).json({
      success: true,
      count: articles.length,
      data: articles
    });
  } catch (error) {
    console.error('Error en getAllArticles:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener artículos'
    });
  }
};

// Obtener un artículo por ID
exports.getArticleById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const article = await Article.findByPk(id);
    
    if (!article) {
      return res.status(404).json({
        success: false,
        message: 'Artículo no encontrado'
      });
    }
    
    res.status(200).json({
      success: true,
      data: article
    });
  } catch (error) {
    console.error('Error en getArticleById:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener artículo'
    });
  }
};

// Obtener artículos favoritos del usuario
exports.getFavoriteArticles = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const favorites = await Favorite.findAll({
      where: { user_id: userId },
      include: [
        {
          model: Article,
          attributes: ['id', 'name', 'description', 'image_url', 'seller', 'rating', 'price']
        }
      ]
    });
    
    // Formatear datos
    const favoriteArticles = favorites.map(favorite => ({
      ...favorite.Article.dataValues,
      favoriteId: favorite.id
    }));
    
    res.status(200).json({
      success: true,
      count: favoriteArticles.length,
      data: favoriteArticles
    });
  } catch (error) {
    console.error('Error en getFavoriteArticles:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener artículos favoritos'
    });
  }
};