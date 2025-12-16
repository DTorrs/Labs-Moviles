const Favorite = require('../models/Favorite');
const Article = require('../models/Article');

// Agregar artículo a favoritos
exports.addFavorite = async (req, res) => {
  try {
    console.log(`Agregando artículo a favoritos. Usuario: ${req.user.id}, Artículo: ${req.body.articleId}`);
    const { articleId } = req.body;
    const userId = req.user.id;
    
    if (!articleId) {
      console.log('Error: No se proporcionó ID de artículo');
      return res.status(400).json({
        success: false,
        message: 'Se requiere el ID del artículo'
      });
    }
    
    // Validar que el artículo exista
    const article = await Article.findByPk(articleId);
    
    if (!article) {
      console.log(`Error: Artículo ${articleId} no encontrado`);
      return res.status(404).json({
        success: false,
        message: 'Artículo no encontrado'
      });
    }
    
    // Verificar si ya está en favoritos
    const existingFavorite = await Favorite.findOne({
      where: {
        user_id: userId,
        article_id: articleId
      }
    });
    
    if (existingFavorite) {
      console.log(`Artículo ${articleId} ya está en favoritos del usuario ${userId}`);
      return res.status(200).json({
        success: true,
        message: 'El artículo ya está en favoritos',
        data: existingFavorite
      });
    }
    
    // Crear favorito
    const favorite = await Favorite.create({
      user_id: userId,
      article_id: articleId
    });
    
    console.log(`Favorito creado exitosamente. ID: ${favorite.id}`);
    res.status(201).json({
      success: true,
      message: 'Artículo agregado a favoritos',
      data: favorite
    });
  } catch (error) {
    console.error('Error en addFavorite:', error);
    res.status(500).json({
      success: false,
      message: 'Error al agregar favorito',
      error: error.message
    });
  }
};

// Eliminar artículo de favoritos
exports.removeFavorite = async (req, res) => {
  try {
    console.log(`Eliminando artículo de favoritos. Usuario: ${req.user.id}, Artículo: ${req.params.articleId}`);
    const { articleId } = req.params;
    const userId = req.user.id;
    
    // Buscar favorito
    const favorite = await Favorite.findOne({
      where: {
        user_id: userId,
        article_id: articleId
      }
    });
    
    if (!favorite) {
      console.log(`Favorito no encontrado. Usuario: ${userId}, Artículo: ${articleId}`);
      return res.status(404).json({
        success: false,
        message: 'Favorito no encontrado'
      });
    }
    
    // Eliminar favorito
    await favorite.destroy();
    
    console.log(`Favorito eliminado exitosamente. Usuario: ${userId}, Artículo: ${articleId}`);
    res.status(200).json({
      success: true,
      message: 'Artículo eliminado de favoritos'
    });
  } catch (error) {
    console.error('Error en removeFavorite:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar favorito',
      error: error.message
    });
  }
};