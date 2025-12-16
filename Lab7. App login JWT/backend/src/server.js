const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes'); // Importa las rutas

const app = express();
const PORT = 3000;

app.use(bodyParser.json());
app.use(cors());

// Usar las rutas de autenticación
app.use('/api/auth', authRoutes);

// Ruta de prueba para verificar que el servidor está corriendo
app.get('/', (req, res) => {
  res.send('Servidor corriendo correctamente');
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});