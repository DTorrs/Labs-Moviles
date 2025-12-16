// src/controllers/userController.js
const User = require('../models/userModel');

// Obtener todos los usuarios
async function getAllUsers(req, res) {
  try {
    const users = await User.getAll();
    res.status(200).json({
      message: 'Usuarios obtenidos exitosamente',
      users
    });
  } catch (error) {
    console.error('Error al obtener usuarios:', error);
    res.status(500).json({ message: 'Error al obtener usuarios', error: error.message });
  }
}

// Obtener usuario por email
async function getUserByEmail(req, res) {
  try {
    const { email } = req.params;
    
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    // No enviar la contraseña
    const { password, ...userData } = user;
    
    res.status(200).json({
      message: 'Usuario obtenido exitosamente',
      user: {
        email: userData.email,
        fullName: userData.full_name,
        phoneNumber: userData.phone_number,
        role: userData.role,
        photoUrl: userData.photo_url
      }
    });
  } catch (error) {
    console.error('Error al obtener usuario:', error);
    res.status(500).json({ message: 'Error al obtener usuario', error: error.message });
  }
}

// Actualizar token FCM
async function updateFcmToken(req, res) {
  try {
    const { email } = req.user;
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
      return res.status(400).json({ message: 'Token FCM es obligatorio' });
    }
    
    await User.saveFcmToken(email, fcmToken);
    
    res.status(200).json({
      message: 'Token FCM actualizado exitosamente'
    });
  } catch (error) {
    console.error('Error al actualizar token FCM:', error);
    res.status(500).json({ message: 'Error al actualizar token FCM', error: error.message });
  }
}

module.exports = {
  getAllUsers,
  getUserByEmail,
  updateFcmToken
};