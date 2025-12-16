// src/middlewares/authMiddleware.js
const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  // Obtener el token del header
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Acceso denegado. Token no proporcionado' });
  }

  try {
    // Verificar el token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido o expirado' });
  }
}

module.exports = authMiddleware;