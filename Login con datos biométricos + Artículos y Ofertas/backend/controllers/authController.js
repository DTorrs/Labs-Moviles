// authController.js

const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

// Generar JWT de sesión (corta vida - 24 horas)
const generateSessionToken = (id) => {
  return jwt.sign({ id, type: 'session' }, process.env.JWT_SECRET || 'secreto123', {
    expiresIn: '24h',
  });
};

// Generar JWT biométrico (larga vida - 90 días)
const generateBiometricToken = (id) => {
  return jwt.sign({ id, type: 'biometric' }, process.env.JWT_SECRET || 'secreto123', {
    expiresIn: '90d',
  });
};

// @desc    Registrar un nuevo usuario
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Verificar que el usuario no exista
    const userExists = await User.findOne({ where: { username } });

    if (userExists) {
      return res.status(400).json({ message: 'El usuario ya existe' });
    }

    // Crear usuario
    const user = await User.create({
      username,
      password,
    });

    if (user) {
      res.status(201).json({
        id: user.id,
        username: user.username,
        biometricEnabled: user.biometricEnabled,
        token: generateSessionToken(user.id),
      });
    } else {
      res.status(400).json({ message: 'Datos de usuario inválidos' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Autenticar usuario
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Encontrar usuario por username
    const user = await User.findOne({ where: { username } });

    // Verificar usuario y contraseña
    if (user && (await user.matchPassword(password))) {
      res.json({
        id: user.id,
        username: user.username,
        biometricEnabled: user.biometricEnabled,
        token: generateSessionToken(user.id),
      });
    } else {
      res.status(401).json({ message: 'Usuario o contraseña incorrectos' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Login con biometría
// @route   POST /api/auth/login/biometric
// @access  Public
const loginWithBiometric = async (req, res) => {
  try {
    const { biometricToken } = req.body;
    
    if (!biometricToken) {
      return res.status(400).json({ message: 'Se requiere token biométrico' });
    }
    
    // Verificar token biométrico
    const decoded = jwt.verify(biometricToken, process.env.JWT_SECRET || 'secreto123');
    
    if (decoded.type !== 'biometric') {
      return res.status(401).json({ message: 'Token biométrico inválido' });
    }
    
    // Encontrar usuario
    const user = await User.findByPk(decoded.id);
    
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    // Verificar que la biometría esté habilitada
    if (!user.biometricEnabled) {
      return res.status(400).json({ message: 'La autenticación biométrica no está habilitada para este usuario' });
    }
    
    // Generar token de sesión
    res.json({
      id: user.id,
      username: user.username,
      biometricEnabled: user.biometricEnabled,
      token: generateSessionToken(user.id), // Token de sesión (corta vida)
    });
  } catch (error) {
    res.status(401).json({ message: 'Token inválido o expirado' });
  }
};

// @desc    Activar/Desactivar autenticación biométrica
// @route   PUT /api/auth/biometric
// @access  Private
const toggleBiometric = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);

    if (user) {
      user.biometricEnabled = req.body.enabled;
      
      await user.save();

      res.json({
        id: user.id,
        username: user.username,
        biometricEnabled: user.biometricEnabled,
      });
    } else {
      res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Genera token biométrico (al habilitar biometría)
// @route   POST /api/auth/biometric/token
// @access  Private
const generateBiometricTokenEndpoint = async (req, res) => {
  try {
    // El usuario ya está autenticado gracias al middleware 'protect'
    const user = await User.findByPk(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    // Generar token biométrico de larga duración
    const biometricToken = generateBiometricToken(user.id);
    
    res.json({
      biometricToken
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { 
  registerUser, 
  loginUser, 
  loginWithBiometric, 
  toggleBiometric, 
  generateBiometricTokenEndpoint
};