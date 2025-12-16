const express = require('express');
const router = express.Router();
const { 
  registerUser, 
  loginUser, 
  loginWithBiometric,
  toggleBiometric,
  generateBiometricTokenEndpoint
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/login/biometric', loginWithBiometric);
router.put('/biometric', protect, toggleBiometric);
router.post('/biometric/token', protect, generateBiometricTokenEndpoint);

module.exports = router;