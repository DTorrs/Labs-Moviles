const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Article = require('../models/Article');
const Favorite = require('../models/Favorite');

// Función para popular la base de datos con datos de ejemplo
async function seedDatabase() {
  try {
    console.log('Iniciando población de la base de datos...');

    // Crear usuarios de prueba
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('password123', salt);

    const users = await User.bulkCreate([
      {
        username: 'usuario1',
        email: 'usuario1@example.com',
        password: passwordHash,
        created_at: new Date(),
        last_login: new Date()
      },
      {
        username: 'usuario2',
        email: 'usuario2@example.com',
        password: passwordHash,
        created_at: new Date(),
        last_login: new Date()
      }
    ]);

    console.log(`Se crearon ${users.length} usuarios de prueba.`);

    // Crear artículos de prueba
    const articles = await Article.bulkCreate([
      {
        name: 'Smartphone Galaxy S23',
        description: 'Smartphone de última generación con cámara de alta resolución.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Electrónica TechStore',
        rating: 4.7,
        price: 999.99,
        created_at: new Date()
      },
      {
        name: 'Laptop Ultradelgada',
        description: 'Laptop potente y ligera para trabajo y entretenimiento.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'PC & Accesorios',
        rating: 4.5,
        price: 1299.99,
        created_at: new Date()
      },
      {
        name: 'Audífonos Inalámbricos',
        description: 'Audífonos con cancelación de ruido y conexión Bluetooth.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Audio Premium',
        rating: 4.8,
        price: 199.99,
        created_at: new Date()
      },
      {
        name: 'Smartwatch Deportivo',
        description: 'Reloj inteligente con monitor de ritmo cardíaco y GPS.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Deportes Xtreme',
        rating: 4.2,
        price: 249.99,
        created_at: new Date()
      },
      {
        name: 'Tableta Gráfica',
        description: 'Tableta para diseñadores profesionales.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Tienda de Arte Digital',
        rating: 4.6,
        price: 349.99,
        created_at: new Date()
      },
      {
        name: 'Cámara DSLR',
        description: 'Cámara profesional para fotos de alta calidad.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Foto Studio',
        rating: 4.9,
        price: 899.99,
        created_at: new Date()
      },
      {
        name: 'Consola de Videojuegos',
        description: 'La última consola con gráficos de alta definición.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Gaming World',
        rating: 4.7,
        price: 499.99,
        created_at: new Date()
      },
      {
        name: 'Altavoz Inteligente',
        description: 'Altavoz con asistente virtual integrado.',
        image_url: 'https://via.placeholder.com/300',
        seller: 'Smart Home',
        rating: 4.4,
        price: 129.99,
        created_at: new Date()
      }
    ]);

    console.log(`Se crearon ${articles.length} artículos de prueba.`);

    // Crear algunos favoritos de prueba
    const favorites = await Favorite.bulkCreate([
      {
        user_id: users[0].id,
        article_id: articles[0].id,
        created_at: new Date()
      },
      {
        user_id: users[0].id,
        article_id: articles[2].id,
        created_at: new Date()
      },
      {
        user_id: users[1].id,
        article_id: articles[1].id,
        created_at: new Date()
      },
      {
        user_id: users[1].id,
        article_id: articles[3].id,
        created_at: new Date()
      }
    ]);

    console.log(`Se crearon ${favorites.length} favoritos de prueba.`);
    console.log('Base de datos poblada exitosamente.');

  } catch (error) {
    console.error('Error al poblar la base de datos:', error);
  }
}

module.exports = seedDatabase;