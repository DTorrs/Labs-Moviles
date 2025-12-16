const admin = require('firebase-admin');
const path = require('path');

// Ajusta la ruta donde colocarás tu archivo serviceAccountKey.json
const serviceAccount = require(path.join(__dirname, '../../serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

module.exports = admin;