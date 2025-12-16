// src/controllers/messageController.js
const Message = require('../models/messageModel');
const User = require('../models/userModel');
const FirebaseService = require('../services/firebaseService');

// Enviar mensaje
async function sendMessage(req, res) {
  try {
    const { title, body, receiverEmail } = req.body;
    const senderEmail = req.user.email;
    
    // Validar datos
    if (!title || !body || !receiverEmail) {
      return res.status(400).json({ message: 'Título, cuerpo y destinatario son obligatorios' });
    }
    
    // Verificar que el destinatario existe
    const receiver = await User.findByEmail(receiverEmail);
    if (!receiver) {
      return res.status(404).json({ message: 'Destinatario no encontrado' });
    }
    
    // Crear mensaje
    const messageData = {
      title,
      body,
      senderEmail,
      receiverEmail
    };
    
    const message = await Message.create(messageData);
    
    // Enviar notificación push
    const notificationResult = await FirebaseService.sendNotificationToUser(
      receiverEmail,
      messageData,
      message.id
    );
    
    res.status(201).json({
      message: 'Mensaje enviado exitosamente',
      data: message,
      notification: notificationResult
    });
  } catch (error) {
    console.error('Error al enviar mensaje:', error);
    res.status(500).json({ message: 'Error al enviar mensaje', error: error.message });
  }
}

// Obtener mensajes recibidos
async function getReceivedMessages(req, res) {
  try {
    const userEmail = req.user.email;
    
    const messages = await Message.getReceivedMessages(userEmail);
    
    res.status(200).json({
      message: 'Mensajes obtenidos exitosamente',
      messages
    });
  } catch (error) {
    console.error('Error al obtener mensajes:', error);
    res.status(500).json({ message: 'Error al obtener mensajes', error: error.message });
  }
}

module.exports = {
  sendMessage,
  getReceivedMessages
};