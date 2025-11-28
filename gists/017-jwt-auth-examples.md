# JWT Authentication Best Practices

> Complete guide to JWT implementation, token storage, rotation, and security

## Table of Contents

- [What is JWT?](#what-is-jwt)
- [JWT Structure](#jwt-structure)
- [Token Types](#token-types)
- [Implementation Patterns](#implementation-patterns)
- [Token Storage](#token-storage)
- [Token Rotation](#token-rotation)
- [Security Best Practices](#security-best-practices)
- [Code Examples](#code-examples)
- [Common Mistakes](#common-mistakes)

---

## What is JWT?

JSON Web Token (JWT) is an open standard (RFC 7519) for securely transmitting information between parties as a JSON object. JWTs are commonly used for:

- **Authentication**: After login, subsequent requests include the JWT
- **Authorization**: JWTs can contain claims about user permissions
- **Information Exchange**: Securely transmit data between parties

### When to Use JWT

✅ **Good use cases:**
- Stateless authentication for APIs
- Microservices communication
- Single Sign-On (SSO)
- Mobile app authentication

❌ **Consider alternatives when:**
- Need immediate token revocation (use sessions)
- Tokens need to be larger than ~8KB (use opaque tokens)
- Server-side session management is acceptable

---

## JWT Structure

A JWT consists of three parts separated by dots: `header.payload.signature`

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### Header

```json
{
  "alg": "HS256",  // Algorithm: HS256, RS256, ES256
  "typ": "JWT"     // Token type
}
```

### Payload (Claims)

```json
{
  // Registered claims (recommended but not required)
  "iss": "https://api.example.com",  // Issuer
  "sub": "user123",                   // Subject (user ID)
  "aud": "https://app.example.com",   // Audience
  "exp": 1516239122,                  // Expiration time
  "nbf": 1516239022,                  // Not before
  "iat": 1516239022,                  // Issued at
  "jti": "unique-token-id",           // JWT ID

  // Public claims (application-specific)
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin"
}
```

### Signature

```javascript
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

---

## Token Types

### Access Token

- **Purpose**: Authorize API requests
- **Lifetime**: Short (5-15 minutes)
- **Storage**: Memory or secure cookie
- **Contains**: User identity and permissions

### Refresh Token

- **Purpose**: Obtain new access tokens
- **Lifetime**: Long (days to weeks)
- **Storage**: HTTP-only cookie or secure storage
- **Contains**: Minimal claims (just user ID)

### ID Token (OpenID Connect)

- **Purpose**: User identity information
- **Lifetime**: Short (same as access token)
- **Storage**: Not stored, used once
- **Contains**: User profile information

---

## Implementation Patterns

### 1. Access Token Only (Simple)

```
┌─────────┐                              ┌─────────┐
│  Client │                              │  Server │
└────┬────┘                              └────┬────┘
     │                                        │
     │  1. Login (username, password)         │
     │ ─────────────────────────────────────> │
     │                                        │
     │  2. Access Token (short-lived)         │
     │ <───────────────────────────────────── │
     │                                        │
     │  3. API Request + Access Token         │
     │ ─────────────────────────────────────> │
     │                                        │
     │  4. Response                           │
     │ <───────────────────────────────────── │
```

**Pros**: Simple implementation  
**Cons**: Frequent re-authentication when token expires

### 2. Access + Refresh Token (Recommended)

```
┌─────────┐                              ┌─────────┐
│  Client │                              │  Server │
└────┬────┘                              └────┬────┘
     │                                        │
     │  1. Login                              │
     │ ─────────────────────────────────────> │
     │                                        │
     │  2. Access Token + Refresh Token       │
     │ <───────────────────────────────────── │
     │                                        │
     │  3. API Request + Access Token         │
     │ ─────────────────────────────────────> │
     │                                        │
     │  4. Response                           │
     │ <───────────────────────────────────── │
     │                                        │
     │  ... Access Token expires ...          │
     │                                        │
     │  5. Refresh Request + Refresh Token    │
     │ ─────────────────────────────────────> │
     │                                        │
     │  6. New Access Token                   │
     │ <───────────────────────────────────── │
```

---

## Token Storage

### Browser Applications

| Storage | Security | XSS Risk | CSRF Risk | Recommendation |
|---------|----------|----------|-----------|----------------|
| localStorage | Low | High | None | ❌ Avoid |
| sessionStorage | Low | High | None | ❌ Avoid |
| Memory | High | Low | None | ✅ Access tokens |
| HTTP-only Cookie | High | None | Medium | ✅ Refresh tokens |

### Recommended: Cookie + Memory Hybrid

```javascript
// Access token in memory
let accessToken = null;

// Refresh token in HTTP-only cookie (set by server)
// Set-Cookie: refreshToken=xxx; HttpOnly; Secure; SameSite=Strict; Path=/api/auth

async function getAccessToken() {
  if (accessToken && !isExpired(accessToken)) {
    return accessToken;
  }
  
  // Refresh token is sent automatically via cookie
  const response = await fetch('/api/auth/refresh', {
    method: 'POST',
    credentials: 'include'
  });
  
  if (response.ok) {
    const data = await response.json();
    accessToken = data.accessToken;
    return accessToken;
  }
  
  throw new Error('Session expired');
}
```

### Mobile Applications

```javascript
// iOS: Keychain
// Android: Encrypted SharedPreferences or Keystore

// React Native example with expo-secure-store
import * as SecureStore from 'expo-secure-store';

async function saveToken(key, value) {
  await SecureStore.setItemAsync(key, value);
}

async function getToken(key) {
  return await SecureStore.getItemAsync(key);
}
```

---

## Token Rotation

### Refresh Token Rotation

Each time a refresh token is used, issue a new one and invalidate the old:

```javascript
// Server-side
async function refreshTokens(refreshToken) {
  // 1. Validate refresh token
  const decoded = verifyRefreshToken(refreshToken);
  
  // 2. Check if token is in database (not revoked)
  const storedToken = await db.refreshTokens.find(refreshToken);
  if (!storedToken) {
    // Possible token reuse - revoke all user tokens
    await revokeAllUserTokens(decoded.userId);
    throw new Error('Token reuse detected');
  }
  
  // 3. Delete old token
  await db.refreshTokens.delete(refreshToken);
  
  // 4. Generate new tokens
  const newAccessToken = generateAccessToken(decoded.userId);
  const newRefreshToken = generateRefreshToken(decoded.userId);
  
  // 5. Store new refresh token
  await db.refreshTokens.create({
    token: newRefreshToken,
    userId: decoded.userId,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  });
  
  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
}
```

### Automatic Token Refresh (Client)

```javascript
// Axios interceptor for automatic refresh
import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  withCredentials: true
});

let isRefreshing = false;
let refreshSubscribers = [];

function subscribeTokenRefresh(callback) {
  refreshSubscribers.push(callback);
}

function onTokenRefreshed(token) {
  refreshSubscribers.forEach(callback => callback(token));
  refreshSubscribers = [];
}

api.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise(resolve => {
          subscribeTokenRefresh(token => {
            originalRequest.headers.Authorization = `Bearer ${token}`;
            resolve(api(originalRequest));
          });
        });
      }
      
      originalRequest._retry = true;
      isRefreshing = true;
      
      try {
        const { data } = await axios.post('/api/auth/refresh');
        const newToken = data.accessToken;
        
        api.defaults.headers.Authorization = `Bearer ${newToken}`;
        onTokenRefreshed(newToken);
        
        originalRequest.headers.Authorization = `Bearer ${newToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        // Redirect to login
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }
    
    return Promise.reject(error);
  }
);
```

---

## Security Best Practices

### Token Generation

```javascript
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

// 1. Use strong secrets (min 256 bits)
const JWT_SECRET = process.env.JWT_SECRET; // Should be 32+ random bytes
// Generate: crypto.randomBytes(32).toString('hex')

// 2. Use asymmetric keys for distributed systems
const privateKey = fs.readFileSync('private.key');
const publicKey = fs.readFileSync('public.key');

// 3. Include necessary claims only
function generateAccessToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role,
      // Don't include sensitive data!
    },
    JWT_SECRET,
    {
      expiresIn: '15m',
      issuer: 'https://api.example.com',
      audience: 'https://app.example.com',
      jwtid: crypto.randomUUID()
    }
  );
}

// 4. Validate all claims on verification
function verifyAccessToken(token) {
  return jwt.verify(token, JWT_SECRET, {
    issuer: 'https://api.example.com',
    audience: 'https://app.example.com',
    algorithms: ['HS256'] // Explicitly specify allowed algorithms!
  });
}
```

### Cookie Security

```javascript
// Express.js example
res.cookie('refreshToken', token, {
  httpOnly: true,       // No JavaScript access
  secure: true,         // HTTPS only
  sameSite: 'strict',   // CSRF protection
  path: '/api/auth',    // Limit scope
  maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
});
```

### Security Checklist

- [ ] Use HTTPS everywhere
- [ ] Use short expiration for access tokens (5-15 min)
- [ ] Implement refresh token rotation
- [ ] Store refresh tokens in HTTP-only cookies
- [ ] Validate all token claims (iss, aud, exp)
- [ ] Use strong, random secrets (256+ bits)
- [ ] Explicitly specify allowed algorithms
- [ ] Implement token revocation mechanism
- [ ] Add rate limiting to auth endpoints
- [ ] Log authentication events
- [ ] Never store tokens in localStorage

---

## Code Examples

### Node.js / Express

```javascript
// auth.middleware.js
import jwt from 'jsonwebtoken';

export function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      algorithms: ['HS256'],
      issuer: process.env.JWT_ISSUER
    });
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(403).json({ error: 'Invalid token' });
  }
}

// auth.routes.js
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  const user = await User.findByEmail(email);
  if (!user || !await user.verifyPassword(password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);
  
  // Store refresh token
  await RefreshToken.create({ token: refreshToken, userId: user.id });
  
  // Set refresh token as HTTP-only cookie
  res.cookie('refreshToken', refreshToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000
  });
  
  res.json({ accessToken, user: user.toJSON() });
});

router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.cookies;
  
  if (!refreshToken) {
    return res.status(401).json({ error: 'Refresh token required' });
  }
  
  try {
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_SECRET);
    
    // Check if token exists in database
    const storedToken = await RefreshToken.findByToken(refreshToken);
    if (!storedToken) {
      return res.status(403).json({ error: 'Invalid refresh token' });
    }
    
    // Rotate tokens
    await RefreshToken.delete(refreshToken);
    
    const newAccessToken = generateAccessToken({ id: decoded.sub });
    const newRefreshToken = generateRefreshToken({ id: decoded.sub });
    
    await RefreshToken.create({ token: newRefreshToken, userId: decoded.sub });
    
    res.cookie('refreshToken', newRefreshToken, { /* same options */ });
    res.json({ accessToken: newAccessToken });
  } catch (err) {
    return res.status(403).json({ error: 'Invalid refresh token' });
  }
});

router.post('/logout', authenticateToken, async (req, res) => {
  const { refreshToken } = req.cookies;
  
  if (refreshToken) {
    await RefreshToken.delete(refreshToken);
  }
  
  res.clearCookie('refreshToken');
  res.json({ message: 'Logged out successfully' });
});
```

### Python / FastAPI

```python
from datetime import datetime, timedelta
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext

# Configuration
SECRET_KEY = "your-secret-key"  # Use env variable
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 7

security = HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(
            credentials.credentials, 
            SECRET_KEY, 
            algorithms=[ALGORITHM]
        )
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if user_id is None or token_type != "access":
            raise credentials_exception
            
    except JWTError:
        raise credentials_exception
    
    user = await get_user(user_id)
    if user is None:
        raise credentials_exception
    
    return user

# Routes
@app.post("/auth/login")
async def login(credentials: LoginRequest):
    user = await authenticate_user(credentials.email, credentials.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token({"sub": str(user.id)})
    refresh_token = create_refresh_token({"sub": str(user.id)})
    
    # Store refresh token in database
    await store_refresh_token(refresh_token, user.id)
    
    response = JSONResponse({"access_token": access_token})
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        secure=True,
        samesite="strict",
        max_age=7 * 24 * 60 * 60
    )
    
    return response

@app.post("/auth/refresh")
async def refresh(request: Request):
    refresh_token = request.cookies.get("refresh_token")
    if not refresh_token:
        raise HTTPException(status_code=401, detail="Refresh token required")
    
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=403, detail="Invalid token type")
        
        # Verify token exists in database
        if not await verify_refresh_token(refresh_token):
            raise HTTPException(status_code=403, detail="Invalid refresh token")
        
        # Rotate tokens
        await delete_refresh_token(refresh_token)
        
        user_id = payload.get("sub")
        new_access_token = create_access_token({"sub": user_id})
        new_refresh_token = create_refresh_token({"sub": user_id})
        
        await store_refresh_token(new_refresh_token, user_id)
        
        response = JSONResponse({"access_token": new_access_token})
        response.set_cookie(
            key="refresh_token",
            value=new_refresh_token,
            httponly=True,
            secure=True,
            samesite="strict"
        )
        
        return response
        
    except JWTError:
        raise HTTPException(status_code=403, detail="Invalid refresh token")
```

---

## Common Mistakes

### ❌ Storing tokens in localStorage

```javascript
// BAD - Vulnerable to XSS
localStorage.setItem('token', accessToken);
```

### ❌ Not validating token claims

```javascript
// BAD - Only verifies signature
jwt.verify(token, secret);

// GOOD - Validates claims
jwt.verify(token, secret, {
  algorithms: ['HS256'],
  issuer: 'https://api.example.com',
  audience: 'https://app.example.com'
});
```

### ❌ Using weak secrets

```javascript
// BAD
const secret = 'mysecret';

// GOOD - Use 256+ bits of entropy
const secret = process.env.JWT_SECRET; // 64-char hex string
```

### ❌ Putting sensitive data in tokens

```javascript
// BAD
const payload = {
  userId: user.id,
  password: user.password,  // NEVER!
  creditCard: user.card     // NEVER!
};

// GOOD
const payload = {
  sub: user.id,
  role: user.role
};
```

### ❌ Not handling token expiration

```javascript
// BAD - No error handling
const decoded = jwt.verify(token, secret);

// GOOD - Handle expiration
try {
  const decoded = jwt.verify(token, secret);
} catch (err) {
  if (err.name === 'TokenExpiredError') {
    // Trigger refresh flow
  } else {
    // Invalid token
  }
}
```

---

**Last Updated**: 2024-01-15  
**Maintainer**: FlashFusion Team
