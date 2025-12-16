// src/models/messageModel.js
const { query } = require('../config/database');

class Message {
  // Crear un nuevo mensaje
  static async create(messageData) {
    try {
      const result = await query(
        'INSERT INTO messages (title, body, sender_email, receiver_email) VALUES (?, ?, ?, ?)',
        [messageData.title, messageData.body, messageData.senderEmail, messageData.receiverEmail]
      );
      
      return {
        id: result.insertId,
        ...messageData,
        createdAt: new Date()
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Registrar notificación enviada
  static async logNotification(messageId, deviceToken, status, responseData = null) {
    try {
      await query(
        'INSERT INTO notifications (message_id, device_token, status, response_data) VALUES (?, ?, ?, ?)',
        [messageId, deviceToken, status, responseData ? JSON.stringify(responseData) : null]
      );
      
      return true;
    } catch (error) {
      throw error;
    }
  }
  
  // Obtener mensajes recibidos por un usuario
  static async getReceivedMessages(userEmail) {
    try {
      const messages = await query(
        `SELECT m.id, m.title, m.body, m.sender_email, m.created_at, 
                u.full_name as sender_name, u.photo_url as sender_photo
         FROM messages m
         JOIN users u ON m.sender_email = u.email
         WHERE m.receiver_email = ?
         ORDER BY m.created_at DESC`,
        [userEmail]
      );
      
      return messages.map(message => ({
        id: message.id,
        title: message.title,
        body: message.body,
        senderEmail: message.sender_email,
        senderName: message.sender_name,
        senderPhoto: message.sender_photo,
        createdAt: message.created_at
      }));
    } catch (error) {
      throw error;
    }
  }
  
  // Obtener mensaje por ID
  static async getById(messageId) {
    try {
      const messages = await query('SELECT * FROM messages WHERE id = ?', [messageId]);
      return messages.length ? messages[0] : null;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Message;