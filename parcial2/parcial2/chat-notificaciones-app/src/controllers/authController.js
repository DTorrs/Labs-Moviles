// src/controllers/authController.js
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const path = require('path');
const fs = require('fs');

// Generar token JWT
function generateToken(user) {
  return jwt.sign(
    { email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
}

// Registro de usuario
async function register(req, res) {
  try {
    const { email, password, fullName, phoneNumber, role, fcmToken } = req.body;
    
    // Validar datos
    if (!email || !password || !fullName || !phoneNumber || !role) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios' });
    }
    
    // Verificar si el usuario ya existe
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: 'El email ya está registrado' });
    }
    
    // Guardar la foto si existe
    let photoUrl = null;
    if (req.file) {
      photoUrl = `/uploads/${req.file.filename}`;
    }
    
    // Crear usuario
    const userData = {
      email,
      password,
      fullName,
      phoneNumber,
      role,
      photoUrl
    };
    
    const user = await User.create(userData, fcmToken);
    
    // Generar token
    const token = generateToken(user);
    
    res.status(201).json({
      message: 'Usuario registrado exitosamente',
      user,
      token
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ message: 'Error al registrar usuario', error: error.message });
  }
}

// Login
async function login(req, res) {
  try {
    const { email, password, fcmToken } = req.body;
    
    // Validar datos
    if (!email || !password) {
      return res.status(400).json({ message: 'Email y contraseña son obligatorios' });
    }
    
    // Verificar credenciales
    const user = await User.checkCredentials(email, password);
    if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    
    // Guardar token FCM si existe
    if (fcmToken) {
      await User.saveFcmToken(email, fcmToken);
    }
    
    // Generar token
    const token = generateToken(user);
    
    res.status(200).json({
      message: 'Login exitoso',
      user,
      token
    });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ message: 'Error al iniciar sesión', error: error.message });
  }
}

module.exports = {
  register,
  login
};