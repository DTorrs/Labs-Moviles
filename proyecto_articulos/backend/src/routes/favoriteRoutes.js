const express = require('express');
const favoriteController = require('../controllers/favoriteController');
const authenticateJWT = require('../middleware/auth');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticateJWT);

router.post('/', favoriteController.addFavorite);
router.delete('/:articleId', favoriteController.removeFavorite);

module.exports = router;