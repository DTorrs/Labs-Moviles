const express = require('express');
const authController = require('../controllers/authController');
const authMiddleware = require('../middlewares/authMiddleware'); // Middleware para verificar el token

const router = express.Router();

// Ruta de login
router.post('/login', authController.login);

// Ruta protegida (requiere token JWT válido)
router.get('/protected', authMiddleware, (req, res) => {
  res.json({
    message: 'Esta es una ruta protegida',
    user: req.user, // Información del usuario decodificada del token
  });
});

// Ruta de perfil de usuario (requiere token JWT válido)
router.get('/profile', authMiddleware, (req, res) => {
  res.json({
    message: 'Perfil de usuario',
    user: req.user, // Información del usuario decodificada del token
  });
});

module.exports = router;