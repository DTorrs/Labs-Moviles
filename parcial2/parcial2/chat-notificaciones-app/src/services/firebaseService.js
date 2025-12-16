// src/services/firebaseService.js
const admin = require('../config/firebase');
const Message = require('../models/messageModel');

class FirebaseService {
  // Enviar notificación push a un dispositivo
  // Enviar notificación push a un dispositivo
static async sendNotification(deviceToken, messageData, messageId) {
  try {
    // Crear payload de notificación
    const message = {
      token: deviceToken,  // Cambio aquí: se envía a un solo token
      notification: {
        title: messageData.title,
        body: messageData.body,
      },
      data: {
        messageId: messageId.toString(),
        senderEmail: messageData.senderEmail,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        priority: 'high',
      },
    };

    // Enviar notificación usando el método correcto
    const response = await admin.messaging().send(message);  // Método correcto

    // Procesar respuesta
    let status = 'success';
    
    // Registrar resultado
    await Message.logNotification(
      messageId,
      deviceToken,
      status,
      { messageId: response }
    );

    return {
      success: true,
      deviceToken,
      result: response
    };
  } catch (error) {
    console.error('Error al enviar notificación:', error);
    // Registrar error
    await Message.logNotification(
      messageId,
      deviceToken,
      'error',
      { error: error.message }
    );

    return {
      success: false,
      deviceToken,
      error: error.message
    };
  }
}
  
  // Enviar notificación a todos los dispositivos de un usuario
  // Para enviar a múltiples dispositivos, usa sendMulticast
static async sendNotificationToUser(userEmail, messageData, messageId) {
  const User = require('../models/userModel');

  try {
    // Obtener tokens FCM del usuario
    const deviceTokens = await User.getFcmTokens(userEmail);

    if (!deviceTokens.length) {
      return {
        success: false,
        message: 'No se encontraron dispositivos para este usuario'
      };
    }

    // Si hay múltiples tokens, usar sendMulticast
    if (deviceTokens.length > 1) {
      const message = {
        tokens: deviceTokens,  // Array de tokens
        notification: {
          title: messageData.title,
          body: messageData.body,
        },
        data: {
          messageId: messageId.toString(),
          senderEmail: messageData.senderEmail,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
        android: {
          priority: 'high',
        },
      };

      const response = await admin.messaging().sendMulticast(message);
      
      // Registrar resultados
      for (let i = 0; i < deviceTokens.length; i++) {
        await Message.logNotification(
          messageId,
          deviceTokens[i],
          response.responses[i].success ? 'success' : 'error',
          response.responses[i]
        );
      }

      return {
        success: true,
        totalDevices: deviceTokens.length,
        successCount: response.successCount
      };
    } else {
      // Si hay un solo token, usar el método individual
      return await this.sendNotification(deviceTokens[0], messageData, messageId);
    }
  } catch (error) {
    console.error('Error al enviar notificaciones:', error);
    throw error;
  }
}
}

module.exports = FirebaseService;