const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

// Generar JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secreto123', {
    expiresIn: '30d',
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
        token: generateToken(user.id),
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
        token: generateToken(user.id),
      });
    } else {
      res.status(401).json({ message: 'Usuario o contraseña incorrectos' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
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

module.exports = { registerUser, loginUser, toggleBiometric };