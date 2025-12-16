const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Op } = require('sequelize');

// Cargar variables de entorno
dotenv.config();

// Importar rutas
const authRoutes = require('./routes/authRoutes');
const articleRoutes = require('./routes/articleRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');

// Importar conexión a la base de datos
const sequelize = require('./config/database');
const User = require('./models/User');
const Article = require('./models/Article');

// Inicializar app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/auth', authRoutes);
app.use('/api/articles', articleRoutes);
app.use('/api/favorites', favoriteRoutes);

// Ruta principal
app.get('/', (req, res) => {
  res.json({ message: 'API de Artículos' });
});

// Ruta para errores
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta no encontrada' });
});

// Puerto
const PORT = process.env.PORT || 3000;

// Importar función para poblar datos
const seedDatabase = require('./utils/seedData');

// Verificar si la base de datos necesita ser poblada
const checkAndSeedDatabase = async () => {
  try {
    // Verificar si ya existen usuarios en la BD
    const userCount = await User.count();
    const articleCount = await Article.count();
    
    if (userCount === 0 || articleCount === 0) {
      console.log('Base de datos vacía, poblando con datos iniciales...');
      await seedDatabase();
    } else {
      console.log(`Base de datos ya contiene ${userCount} usuarios y ${articleCount} artículos.`);
    }
  } catch (error) {
    console.error('Error al verificar/poblar base de datos:', error);
  }
};

// Iniciar servidor
const startServer = async () => {
  try {
    // Verificar conexión a la base de datos
    await sequelize.authenticate();
    console.log('Conexión a la base de datos establecida.');
    
    // CAMBIO IMPORTANTE: Sincronizar modelos SIN forzar recreación
    // Usar { force: false } para mantener los datos existentes
    await sequelize.sync({ force: false });
    console.log('Sincronización de modelos completada.');
    
    // Verificar y poblar la base de datos solo si está vacía
    await checkAndSeedDatabase();
    
    // Iniciar servidor
    app.listen(PORT, () => {
      console.log(`Servidor corriendo en el puerto ${PORT}`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
};

startServer();