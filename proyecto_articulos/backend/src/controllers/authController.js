const jwt = require('jsonwebtoken');
const { Op } = require('sequelize');
const User = require('../models/User');

// Registro de usuario
exports.register = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Validaciones
    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Todos los campos son obligatorios'
      });
    }
    
    // Verificar si el usuario ya existe
    const existingUser = await User.findOne({ 
      where: { 
        [Op.or]: [{ username }, { email }] 
      } 
    });
    
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'El nombre de usuario o email ya está en uso'
      });
    }
    
    // Crear usuario
    const user = await User.create({
      username,
      email,
      password
    });
    
    // Generar token
    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({
      success: false,
      message: 'Error al registrar usuario'
    });
  }
};

// Inicio de sesión
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validaciones
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email y contraseña son obligatorios'
      });
    }
    
    // Buscar usuario
    const user = await User.findOne({ where: { email } });
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Credenciales inválidas'
      });
    }
    
    // Verificar contraseña
    const isMatch = await user.comparePassword(password);
    
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Credenciales inválidas'
      });
    }
    
    // Actualizar último inicio de sesión
    user.last_login = new Date();
    await user.save();
    
    // Generar token
    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    res.status(200).json({
      success: true,
      message: 'Inicio de sesión exitoso',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({
      success: false,
      message: 'Error al iniciar sesión'
    });
  }
};

// Obtener datos del usuario actual
exports.getMe = async (req, res) => {
  try {
    // El middleware auth ya agregó el usuario al objeto req
    const user = req.user;
        
    res.status(200).json({
      success: true,
      message: 'Datos de usuario obtenidos exitosamente',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        created_at: user.created_at || new Date().toISOString(),
        last_login: user.last_login || null
      }
    });
  } catch (error) {
    console.error('Error en getMe:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener datos del usuario'
    });
  }
};