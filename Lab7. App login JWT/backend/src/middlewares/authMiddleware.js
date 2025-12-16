const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  // Obtener el token del encabezado de la solicitud
  const token = req.header('Authorization');

  // Verificar si el token existe
  if (!token) {
    return res.status(401).json({ message: 'Acceso denegado. No hay token proporcionado.' });
  }

  try {
    // Verificar y decodificar el token
    const decoded = jwt.verify(token, 'secreto'); // Usa la misma clave secreta que usaste para generar el token
    req.user = decoded; // Guardar la información del usuario en la solicitud
    next(); // Continuar con la siguiente función (controlador)
  } catch (ex) {
    // Si el token es inválido o ha expirado
    res.status(400).json({ message: 'Token inválido o expirado.' });
  }
};

module.exports = authMiddleware;