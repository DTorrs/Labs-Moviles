// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Importar rutas
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes');
const messageRoutes = require('./src/routes/messageRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Rutas
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/messages', messageRoutes);

// Ruta base
app.get('/', (req, res) => {
  res.send('API de Chat con Notificaciones funcionando correctamente');
});

// Manejador de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send({ message: 'Error en el servidor', error: err.message });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});