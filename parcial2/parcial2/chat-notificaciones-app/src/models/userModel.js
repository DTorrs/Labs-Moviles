// src/models/userModel.js
const { query } = require('../config/database');
const bcrypt = require('bcrypt');

class User {
  // Crear un nuevo usuario
  static async create(userData, fcmToken) {
    try {
      // Hash de la contraseña
      const hashedPassword = await bcrypt.hash(userData.password, 10);
      
      // Insertar usuario
      await query(
        'INSERT INTO users (email, password, full_name, phone_number, role, photo_url) VALUES (?, ?, ?, ?, ?, ?)',
        [userData.email, hashedPassword, userData.fullName, userData.phoneNumber, userData.role, userData.photoUrl]
      );
      
      // Almacenar token FCM
      if (fcmToken) {
        await query(
          'INSERT INTO device_tokens (user_email, fcm_token) VALUES (?, ?)',
          [userData.email, fcmToken]
        );
      }
      
      // Retornar usuario sin contraseña
      return {
        email: userData.email,
        fullName: userData.fullName,
        phoneNumber: userData.phoneNumber,
        role: userData.role,
        photoUrl: userData.photoUrl
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Encontrar usuario por email
  static async findByEmail(email) {
    try {
      const users = await query('SELECT * FROM users WHERE email = ?', [email]);
      return users.length ? users[0] : null;
    } catch (error) {
      throw error;
    }
  }
  
  // Obtener todos los usuarios
  static async getAll() {
    try {
      const users = await query('SELECT email, full_name, phone_number, role, photo_url FROM users');
      return users.map(user => ({
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number,
        role: user.role,
        photoUrl: user.photo_url
      }));
    } catch (error) {
      throw error;
    }
  }
  
  // Verificar credenciales
  static async checkCredentials(email, password) {
    try {
      const user = await this.findByEmail(email);
      if (!user) return null;
      
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) return null;
      
      return {
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number,
        role: user.role,
        photoUrl: user.photo_url
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Guardar o actualizar token FCM
  static async saveFcmToken(email, fcmToken) {
    try {
      // Verificar si ya existe el token para este usuario
      const existingTokens = await query(
        'SELECT * FROM device_tokens WHERE user_email = ? AND fcm_token = ?',
        [email, fcmToken]
      );
      
      if (existingTokens.length === 0) {
        // Si no existe, insertarlo
        await query(
          'INSERT INTO device_tokens (user_email, fcm_token) VALUES (?, ?)',
          [email, fcmToken]
        );
      } else {
        // Si existe, actualizar la fecha de último uso
        await query(
          'UPDATE device_tokens SET last_used = CURRENT_TIMESTAMP WHERE user_email = ? AND fcm_token = ?',
          [email, fcmToken]
        );
      }
      
      return true;
    } catch (error) {
      throw error;
    }
  }
  
  // Obtener tokens FCM de un usuario
  static async getFcmTokens(email) {
    try {
      const tokens = await query(
        'SELECT fcm_token FROM device_tokens WHERE user_email = ?',
        [email]
      );
      
      return tokens.map(token => token.fcm_token);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = User;