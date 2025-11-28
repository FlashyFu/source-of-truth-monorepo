/**
 * ============================================================================
 * 005-express-jwt-api.js
 * Minimal Express REST API with JWT authentication, rate limiting, and validation
 * ============================================================================
 *
 * HOW TO USE:
 *   1. Install dependencies: npm install express jsonwebtoken bcryptjs express-rate-limit express-validator helmet cors
 *   2. Set environment variables: JWT_SECRET, PORT
 *   3. Run: node express-jwt-api.js
 *   4. Test: curl http://localhost:3000/api/health
 *
 * ENDPOINTS:
 *   POST /api/auth/register - Register new user
 *   POST /api/auth/login    - Login and get JWT
 *   GET  /api/users/me      - Get current user (protected)
 *   GET  /api/health        - Health check
 *
 * SECURITY NOTES:
 *   - Store JWT_SECRET in environment variables
 *   - Use HTTPS in production
 *   - Implement refresh token rotation for production
 *   - Add proper password hashing rounds (10+)
 *
 * ============================================================================
 */

import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import rateLimit from 'express-rate-limit';
import { body, validationResult } from 'express-validator';
import helmet from 'helmet';
import cors from 'cors';

const app = express();

// =============================================================================
// Configuration
// =============================================================================

const config = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET || 'change-this-secret-in-production',
  jwtExpiresIn: '1h',
  saltRounds: 10,
};

// In-memory user store (replace with database in production)
const users = new Map();

// =============================================================================
// Middleware
// =============================================================================

// Security headers
app.use(helmet());

// CORS configuration
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Body parsing
app.use(express.json({ limit: '10kb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  message: { error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Auth-specific rate limiting (stricter)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 attempts per 15 minutes
  message: { error: 'Too many login attempts, please try again later' },
});

// =============================================================================
// Authentication Middleware
// =============================================================================

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, config.jwtSecret);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(403).json({ error: 'Invalid token' });
  }
};

// =============================================================================
// Validation Schemas
// =============================================================================

const registerValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
    .matches(/\d/)
    .withMessage('Password must contain a number')
    .matches(/[A-Z]/)
    .withMessage('Password must contain uppercase letter'),
  body('name').trim().isLength({ min: 2, max: 50 }).withMessage('Name required'),
];

const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password').notEmpty().withMessage('Password required'),
];

// =============================================================================
// Helper Functions
// =============================================================================

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

const generateToken = (user) => {
  return jwt.sign({ id: user.id, email: user.email }, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn,
  });
};

// =============================================================================
// Routes
// =============================================================================

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Register
app.post(
  '/api/auth/register',
  authLimiter,
  registerValidation,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { email, password, name } = req.body;

      // Check if user exists
      if (users.has(email)) {
        return res.status(409).json({ error: 'Email already registered' });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, config.saltRounds);

      // Create user
      const user = {
        id: crypto.randomUUID(),
        email,
        name,
        password: hashedPassword,
        createdAt: new Date().toISOString(),
      };

      users.set(email, user);

      // Generate token
      const token = generateToken(user);

      res.status(201).json({
        message: 'User registered successfully',
        token,
        user: { id: user.id, email: user.email, name: user.name },
      });
    } catch (err) {
      console.error('Registration error:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);

// Login
app.post(
  '/api/auth/login',
  authLimiter,
  loginValidation,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { email, password } = req.body;

      // Find user
      const user = users.get(email);
      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Verify password
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate token
      const token = generateToken(user);

      res.json({
        message: 'Login successful',
        token,
        user: { id: user.id, email: user.email, name: user.name },
      });
    } catch (err) {
      console.error('Login error:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);

// Get current user (protected)
app.get('/api/users/me', authenticateToken, (req, res) => {
  const user = Array.from(users.values()).find((u) => u.id === req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({
    id: user.id,
    email: user.email,
    name: user.name,
    createdAt: user.createdAt,
  });
});

// =============================================================================
// Error Handling
// =============================================================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// =============================================================================
// Server Start
// =============================================================================

app.listen(config.port, () => {
  console.log(`🚀 Server running on port ${config.port}`);
  console.log(`📋 Health check: http://localhost:${config.port}/api/health`);
});

export default app;

/**
 * ============================================================================
 * PRODUCTION CHECKLIST:
 * - [ ] Use environment variables for all secrets
 * - [ ] Implement refresh token rotation
 * - [ ] Add request logging (morgan, winston)
 * - [ ] Connect to a real database (PostgreSQL, MongoDB)
 * - [ ] Add input sanitization
 * - [ ] Implement proper password policies
 * - [ ] Add HTTPS termination
 * - [ ] Set up monitoring and alerting
 * - [ ] Implement graceful shutdown
 * ============================================================================
 */
