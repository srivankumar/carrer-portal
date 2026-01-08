import express from 'express';
import { register, login, getProfile, checkEmailExists } from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/check-email', checkEmailExists);
router.get('/profile', authenticate, getProfile);

export default router;
