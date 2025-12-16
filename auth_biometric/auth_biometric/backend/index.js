require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');

// Inicializar app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/auth', authRoutes);

// Ruta básica
app.get('/', (req, res) => {
  res.send('API para autenticación biométrica funcionando');
});

// Sincronizar base de datos
db.sync()
  .then(() => console.log('Modelos sincronizados con la base de datos'))
  .catch(err => console.error('Error al sincronizar modelos:', err));

// Puerto y servidor
const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0'; // Esto permite conexiones desde cualquier dirección

app.listen(PORT, HOST, () => console.log(`Servidor iniciado en ${HOST}:${PORT}`));
