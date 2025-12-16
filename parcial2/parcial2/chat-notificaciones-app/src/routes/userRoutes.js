// src/routes/userRoutes.js
const express = require('express');
const { getAllUsers, getUserByEmail, updateFcmToken } = require('../controllers/userController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Aplicar middleware de autenticación a todas las rutas
router.use(authMiddleware);

// Obtener todos los usuarios
router.get('/', getAllUsers);

// Obtener usuario por email
router.get('/:email', getUserByEmail);

// Actualizar token FCM
router.post('/fcm-token', updateFcmToken);

module.exports = router;