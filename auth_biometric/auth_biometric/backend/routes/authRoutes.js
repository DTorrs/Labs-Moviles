const express = require('express');
const router = express.Router();
const { 
  registerUser, 
  loginUser, 
  toggleBiometric 
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.put('/biometric', protect, toggleBiometric);

module.exports = router;