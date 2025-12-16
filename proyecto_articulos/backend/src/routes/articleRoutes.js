const express = require('express');
const articleController = require('../controllers/articleController');
const authenticateJWT = require('../middleware/auth');

const router = express.Router();

// Rutas públicas
router.get('/', articleController.getAllArticles);
router.get('/:id', articleController.getArticleById);

// Rutas protegidas
router.get('/user/favorites', authenticateJWT, articleController.getFavoriteArticles);

module.exports = router;