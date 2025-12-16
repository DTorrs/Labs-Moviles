const express = require('express');
const authController = require('../controllers/authController');
const authenticateJWT = require('../middleware/auth');

const router = express.Router();

// Rutas públicas
router.post('/register', authController.register);
router.post('/login', authController.login);

// Rutas protegidas
router.get('/me', authenticateJWT, authController.getMe);

module.exports = router;