const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const generateToken = require('../utils/generateToken');

const usersFilePath = path.join(__dirname, '../users.json');
const users = JSON.parse(fs.readFileSync(usersFilePath, 'utf-8'));

const login = (req, res) => {
  const { email, password } = req.body;

  // Buscar al usuario en el archivo JSON
  const user = users.find(u => u.email === email && u.password === password);

  if (!user) {
    return res.status(401).json({ message: 'Credenciales inválidas' });
  }

  // Generar un token JWT
  const token = generateToken(user);

  // Enviar el token como respuesta
  res.json({ token });
};

module.exports = { login };