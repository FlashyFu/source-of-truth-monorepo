// Minimal Express API with JWT auth, request validation, rate limiting and graceful error handling.
//
// Usage:
//   NODE_ENV=development JWT_SECRET=replace_with_secret node express-jwt-api.js
//
// Endpoints:
//   POST /auth/login   -> returns { accessToken }
//   GET  /profile      -> protected; requires Authorization: Bearer <token>

const express = require('express');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const { body, validationResult } = require('express-validator');

const app = express();
app.use(helmet());
app.use(bodyParser.json());

// Config (use env vars in production)
const JWT_SECRET = process.env.JWT_SECRET || 'replace_with_secret';
const PORT = process.env.PORT || 3000;
const TOKEN_EXPIRY = '15m';

// Simple in-memory store (replace with DB)
const users = { 'alice@example.com': { password: 'password123', id: 'user-1', name: 'Alice' } };

// Rate limiter for auth endpoints
const authLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  message: { error: 'Too many auth attempts, try again later' }
});

// Rate limiter for API endpoints
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: { error: 'Too many requests, try again later' }
});

app.post('/auth/login', authLimiter, [
  body('email').isEmail(),
  body('password').isString().isLength({ min: 6 })
], (req, res) => {
  const errors = validationResult(req);
  if(!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { email, password } = req.body;
  const user = users[email];
  if(!user || user.password !== password) return res.status(401).json({ error: 'Invalid credentials' });

  const payload = { sub: user.id, email };
  const token = jwt.sign(payload, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });

  res.json({ accessToken: token, expiresIn: TOKEN_EXPIRY });
});

// Middleware to verify JWT
function authenticate(req, res, next) {
  const header = req.header('Authorization');
  if(!header) return res.status(401).json({ error: 'Missing Authorization header' });

  const parts = header.split(' ');
  if(parts.length !== 2 || parts[0] !== 'Bearer') return res.status(401).json({ error: 'Invalid Authorization format' });

  const token = parts[1];
  jwt.verify(token, JWT_SECRET, (err, payload) => {
    if(err) return res.status(401).json({ error: 'Invalid or expired token' });
    req.user = payload;
    next();
  });
}

app.get('/profile', apiLimiter, authenticate, (req, res) => {
  // Fetch user details
  const user = Object.values(users).find(u => u.id === req.user.sub);
  if(!user) return res.status(404).json({ error: 'User not found' });

  res.json({ id: user.id, name: user.name, email: req.user.email });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

if(require.main === module) {
  app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
}

// Export app for testing
module.exports = app;
