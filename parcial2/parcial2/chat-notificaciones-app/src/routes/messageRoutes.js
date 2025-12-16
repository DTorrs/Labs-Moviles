// src/routes/messageRoutes.js
const express = require('express');
const { sendMessage, getReceivedMessages } = require('../controllers/messageController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Aplicar middleware de autenticación a todas las rutas
router.use(authMiddleware);

// Enviar mensaje
router.post('/send', sendMessage);

// Obtener mensajes recibidos
router.get('/received', getReceivedMessages);

module.exports = router;