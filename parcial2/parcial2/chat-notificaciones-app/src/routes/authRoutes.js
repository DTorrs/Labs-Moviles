// src/routes/authRoutes.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { register, login } = require('../controllers/authController');

const router = express.Router();

// Configuración de multer para subir fotos
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../uploads');
    
    // Crear directorio si no existe
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'user-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    
    cb(new Error('Solo se permiten imágenes (jpeg, jpg, png)'));
  }
});

// Ruta de registro
router.post('/register', upload.single('photo'), register);

// Ruta de login
router.post('/login', login);

module.exports = router;