const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email }, // Datos que quieres incluir en el token
    'secreto', // Clave secreta (debería estar en una variable de entorno)
    { expiresIn: '1h' } // Tiempo de expiración del token
  );
};

module.exports = generateToken;