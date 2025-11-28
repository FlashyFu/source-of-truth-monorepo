# OAuth2 Authorization Flow

> Complete guide to OAuth2 authorization code flow, PKCE, and integration

## Table of Contents

- [Overview](#overview)
- [OAuth2 Roles](#oauth2-roles)
- [Grant Types](#grant-types)
- [Authorization Code Flow](#authorization-code-flow)
- [PKCE Extension](#pkce-extension)
- [Implementation Guide](#implementation-guide)
- [Token Management](#token-management)
- [Security Considerations](#security-considerations)
- [Integration Checklist](#integration-checklist)
- [Provider Examples](#provider-examples)

---

## Overview

OAuth 2.0 is an authorization framework that enables third-party applications to obtain limited access to user accounts on an HTTP service. It works by delegating user authentication to the service that hosts the user account.

### Key Concepts

- **Authorization**: Granting access to resources
- **Authentication**: Verifying identity (handled by OpenID Connect)
- **Delegation**: Acting on behalf of users

### When to Use OAuth2

| Use Case | Recommendation |
|----------|----------------|
| Third-party app accessing user data | ✅ OAuth2 + PKCE |
| First-party mobile/SPA | ✅ OAuth2 + PKCE |
| Server-to-server communication | ✅ Client Credentials |
| Traditional web app with sessions | ✅ Authorization Code |
| Embedded/IoT devices | ✅ Device Code Flow |

---

## OAuth2 Roles

```
┌─────────────────────────────────────────────────────────────────┐
│                        OAuth2 Roles                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │   Resource Owner │         │      Client      │              │
│  │     (User)       │◄───────►│  (Application)   │              │
│  └──────────────────┘         └────────┬─────────┘              │
│                                        │                         │
│                                        │                         │
│  ┌──────────────────┐         ┌────────▼─────────┐              │
│  │ Resource Server  │◄────────│ Authorization    │              │
│  │     (API)        │         │     Server       │              │
│  └──────────────────┘         └──────────────────┘              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

| Role | Description | Example |
|------|-------------|---------|
| Resource Owner | The user who authorizes access | End user |
| Client | The application requesting access | Your web/mobile app |
| Authorization Server | Issues tokens after authenticating user | Google, Auth0, Okta |
| Resource Server | Hosts protected resources (API) | Your API server |

---

## Grant Types

### 1. Authorization Code (Most Secure)

For server-side apps where the client secret can be kept confidential.

```
User ──► Client ──► Auth Server ──► User Login ──► Auth Code ──► Client ──► Tokens
```

### 2. Authorization Code + PKCE (Recommended)

For public clients (SPAs, mobile apps) where client secret cannot be stored securely.

```
Same as above, but with code_verifier/code_challenge for security
```

### 3. Client Credentials

For server-to-server communication without user involvement.

```
Client ──► Auth Server (with client_id + client_secret) ──► Access Token
```

### 4. Device Code

For devices with limited input capabilities (TVs, IoT).

```
Device ──► Get Device Code ──► User enters code on other device ──► Poll for tokens
```

### ~~5. Implicit (Deprecated)~~

Don't use. Replaced by Authorization Code + PKCE.

### ~~6. Resource Owner Password (Deprecated)~~

Don't use. Only for legacy applications.

---

## Authorization Code Flow

### Step-by-Step Flow

```
┌──────┐                                    ┌───────────────┐                ┌──────────────┐
│ User │                                    │    Client     │                │ Auth Server  │
└──┬───┘                                    └───────┬───────┘                └──────┬───────┘
   │                                                │                               │
   │  1. Click "Login with Provider"                │                               │
   │ ──────────────────────────────────────────────>│                               │
   │                                                │                               │
   │  2. Redirect to Authorization Endpoint         │                               │
   │ <──────────────────────────────────────────────│                               │
   │                                                │                               │
   │  3. Enter credentials & consent                │                               │
   │ ─────────────────────────────────────────────────────────────────────────────>│
   │                                                │                               │
   │  4. Redirect with authorization code           │                               │
   │ <─────────────────────────────────────────────────────────────────────────────│
   │                                                │                               │
   │  5. Send code to client                        │                               │
   │ ──────────────────────────────────────────────>│                               │
   │                                                │                               │
   │                                                │  6. Exchange code for tokens  │
   │                                                │ ─────────────────────────────>│
   │                                                │                               │
   │                                                │  7. Return tokens             │
   │                                                │ <─────────────────────────────│
   │                                                │                               │
   │  8. User is authenticated                      │                               │
   │ <──────────────────────────────────────────────│                               │
   │                                                │                               │
```

### Authorization Request

```
GET /authorize?
  response_type=code&
  client_id=YOUR_CLIENT_ID&
  redirect_uri=https://yourapp.com/callback&
  scope=openid profile email&
  state=RANDOM_STATE_STRING
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| response_type | Yes | Must be `code` |
| client_id | Yes | Your application's client ID |
| redirect_uri | Yes | Where to send the user after authorization |
| scope | Yes | Permissions being requested |
| state | Yes | Random string for CSRF protection |

### Token Exchange

```http
POST /token HTTP/1.1
Host: auth.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&
code=AUTHORIZATION_CODE&
redirect_uri=https://yourapp.com/callback&
client_id=YOUR_CLIENT_ID&
client_secret=YOUR_CLIENT_SECRET
```

### Token Response

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "scope": "openid profile email",
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## PKCE Extension

PKCE (Proof Key for Code Exchange) protects against authorization code interception attacks. **Required for public clients.**

### How PKCE Works

```
┌──────────────────────────────────────────────────────────────────┐
│                         PKCE Flow                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Generate code_verifier (random string)                        │
│     └─► code_verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p..."        │
│                                                                   │
│  2. Create code_challenge from verifier                           │
│     └─► code_challenge = BASE64URL(SHA256(code_verifier))        │
│                                                                   │
│  3. Include code_challenge in authorization request               │
│     └─► /authorize?...&code_challenge=E9Melhoa...&                │
│         code_challenge_method=S256                                │
│                                                                   │
│  4. Include code_verifier when exchanging code                    │
│     └─► POST /token { code_verifier: "dBjftJeZ4CVP..." }         │
│                                                                   │
│  5. Server verifies: SHA256(code_verifier) == code_challenge     │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### PKCE Code Example

```javascript
// Generate PKCE values
function generatePKCE() {
  // Generate random code_verifier
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  const codeVerifier = base64URLEncode(array);
  
  // Create code_challenge
  const encoder = new TextEncoder();
  const data = encoder.encode(codeVerifier);
  const digest = await crypto.subtle.digest('SHA-256', data);
  const codeChallenge = base64URLEncode(new Uint8Array(digest));
  
  return { codeVerifier, codeChallenge };
}

function base64URLEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}
```

---

## Implementation Guide

### Node.js / Express Example

```javascript
import express from 'express';
import crypto from 'crypto';

const app = express();

// Configuration
const config = {
  clientId: process.env.OAUTH_CLIENT_ID,
  clientSecret: process.env.OAUTH_CLIENT_SECRET,
  authorizationEndpoint: 'https://auth.example.com/authorize',
  tokenEndpoint: 'https://auth.example.com/token',
  redirectUri: 'https://yourapp.com/callback',
  scopes: ['openid', 'profile', 'email']
};

// Store PKCE verifiers and state (use session/redis in production)
const pendingAuth = new Map();

// Step 1: Initiate OAuth flow
app.get('/auth/login', (req, res) => {
  // Generate PKCE values
  const codeVerifier = crypto.randomBytes(32).toString('base64url');
  const codeChallenge = crypto
    .createHash('sha256')
    .update(codeVerifier)
    .digest('base64url');
  
  // Generate state for CSRF protection
  const state = crypto.randomBytes(16).toString('hex');
  
  // Store for later verification
  pendingAuth.set(state, { codeVerifier, createdAt: Date.now() });
  
  // Build authorization URL
  const params = new URLSearchParams({
    response_type: 'code',
    client_id: config.clientId,
    redirect_uri: config.redirectUri,
    scope: config.scopes.join(' '),
    state: state,
    code_challenge: codeChallenge,
    code_challenge_method: 'S256'
  });
  
  res.redirect(`${config.authorizationEndpoint}?${params}`);
});

// Step 2: Handle callback
app.get('/callback', async (req, res) => {
  const { code, state, error } = req.query;
  
  // Check for errors
  if (error) {
    return res.status(400).json({ error: req.query.error_description });
  }
  
  // Verify state
  const pending = pendingAuth.get(state);
  if (!pending) {
    return res.status(400).json({ error: 'Invalid state parameter' });
  }
  pendingAuth.delete(state);
  
  // Check state expiration (5 minutes)
  if (Date.now() - pending.createdAt > 5 * 60 * 1000) {
    return res.status(400).json({ error: 'Authorization expired' });
  }
  
  try {
    // Exchange code for tokens
    const tokenResponse = await fetch(config.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: config.redirectUri,
        client_id: config.clientId,
        client_secret: config.clientSecret,
        code_verifier: pending.codeVerifier
      })
    });
    
    if (!tokenResponse.ok) {
      throw new Error('Token exchange failed');
    }
    
    const tokens = await tokenResponse.json();
    
    // Create session, set cookies, etc.
    req.session.tokens = tokens;
    
    res.redirect('/dashboard');
  } catch (err) {
    console.error('OAuth error:', err);
    res.status(500).json({ error: 'Authentication failed' });
  }
});

// Step 3: Refresh tokens
app.post('/auth/refresh', async (req, res) => {
  const refreshToken = req.session.tokens?.refresh_token;
  
  if (!refreshToken) {
    return res.status(401).json({ error: 'No refresh token' });
  }
  
  try {
    const response = await fetch(config.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
        client_id: config.clientId,
        client_secret: config.clientSecret
      })
    });
    
    if (!response.ok) {
      req.session.destroy();
      return res.status(401).json({ error: 'Refresh failed' });
    }
    
    const tokens = await response.json();
    req.session.tokens = tokens;
    
    res.json({ access_token: tokens.access_token });
  } catch (err) {
    res.status(500).json({ error: 'Refresh failed' });
  }
});

// Logout
app.post('/auth/logout', (req, res) => {
  req.session.destroy();
  // Optionally: redirect to provider's logout endpoint
  res.json({ message: 'Logged out' });
});
```

### React Frontend Example

```javascript
// useAuth.js
import { useState, useEffect, useCallback } from 'react';

const config = {
  clientId: process.env.REACT_APP_OAUTH_CLIENT_ID,
  authorizationEndpoint: 'https://auth.example.com/authorize',
  tokenEndpoint: 'https://auth.example.com/token',
  redirectUri: window.location.origin + '/callback',
  scopes: ['openid', 'profile', 'email']
};

// PKCE helpers
function generateCodeVerifier() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return base64URLEncode(array);
}

async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return base64URLEncode(new Uint8Array(digest));
}

function base64URLEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

export function useAuth() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const login = useCallback(async () => {
    // Generate PKCE
    const codeVerifier = generateCodeVerifier();
    const codeChallenge = await generateCodeChallenge(codeVerifier);
    const state = crypto.randomUUID();
    
    // Store for callback
    sessionStorage.setItem('oauth_code_verifier', codeVerifier);
    sessionStorage.setItem('oauth_state', state);
    
    // Redirect to authorization
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: config.clientId,
      redirect_uri: config.redirectUri,
      scope: config.scopes.join(' '),
      state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256'
    });
    
    window.location.href = `${config.authorizationEndpoint}?${params}`;
  }, []);

  const handleCallback = useCallback(async () => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');
    const state = params.get('state');
    const error = params.get('error');
    
    if (error) {
      throw new Error(params.get('error_description') || error);
    }
    
    // Verify state
    const savedState = sessionStorage.getItem('oauth_state');
    if (state !== savedState) {
      throw new Error('Invalid state');
    }
    
    const codeVerifier = sessionStorage.getItem('oauth_code_verifier');
    
    // Clean up
    sessionStorage.removeItem('oauth_state');
    sessionStorage.removeItem('oauth_code_verifier');
    
    // Exchange code for tokens
    const response = await fetch(config.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: config.redirectUri,
        client_id: config.clientId,
        code_verifier: codeVerifier
      })
    });
    
    if (!response.ok) {
      throw new Error('Token exchange failed');
    }
    
    const tokens = await response.json();
    
    // Store tokens securely
    // Access token in memory, refresh token in httpOnly cookie via backend
    setAccessToken(tokens.access_token);
    
    return tokens;
  }, []);

  const logout = useCallback(() => {
    setUser(null);
    // Clear tokens
    window.location.href = '/';
  }, []);

  return { user, loading, login, logout, handleCallback };
}
```

---

## Token Management

### Storing Tokens Securely

| Token Type | Storage Location | Notes |
|------------|------------------|-------|
| Access Token | Memory (variable) | Short-lived, refreshed automatically |
| Refresh Token | HTTP-only cookie | Set by backend, not accessible to JS |
| ID Token | Memory or don't store | Use once for user info, discard |

### Token Refresh Strategy

```javascript
// Automatic token refresh with axios interceptor
import axios from 'axios';

const api = axios.create({ baseURL: '/api' });

let accessToken = null;
let refreshPromise = null;

api.interceptors.request.use(config => {
  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }
  return config;
});

api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status !== 401) {
      return Promise.reject(error);
    }
    
    const originalRequest = error.config;
    if (originalRequest._retry) {
      // Already tried refresh, redirect to login
      window.location.href = '/login';
      return Promise.reject(error);
    }
    
    originalRequest._retry = true;
    
    // Only one refresh at a time
    if (!refreshPromise) {
      refreshPromise = refreshTokens()
        .finally(() => { refreshPromise = null; });
    }
    
    try {
      await refreshPromise;
      return api(originalRequest);
    } catch (refreshError) {
      window.location.href = '/login';
      return Promise.reject(refreshError);
    }
  }
);

async function refreshTokens() {
  const response = await fetch('/auth/refresh', {
    method: 'POST',
    credentials: 'include'
  });
  
  if (!response.ok) {
    throw new Error('Refresh failed');
  }
  
  const data = await response.json();
  accessToken = data.access_token;
}
```

---

## Security Considerations

### MUST Do

- ✅ Always use HTTPS
- ✅ Always use PKCE for public clients
- ✅ Always validate the `state` parameter
- ✅ Use short-lived access tokens (15-60 min)
- ✅ Store refresh tokens in HTTP-only cookies
- ✅ Validate token signatures and claims
- ✅ Implement token rotation for refresh tokens
- ✅ Use secure, random values for state and PKCE

### NEVER Do

- ❌ Store tokens in localStorage
- ❌ Include tokens in URL parameters
- ❌ Use the Implicit flow
- ❌ Skip state validation
- ❌ Use predictable state/PKCE values
- ❌ Store client secrets in public clients

### Attack Prevention

| Attack | Prevention |
|--------|------------|
| CSRF | State parameter |
| Authorization Code Interception | PKCE |
| Token Leakage | Short-lived tokens, HTTP-only cookies |
| Replay Attacks | Token binding, nonce (OIDC) |
| Open Redirect | Validate redirect_uri strictly |

---

## Integration Checklist

### Pre-Integration

- [ ] Register application with OAuth provider
- [ ] Obtain client ID and client secret
- [ ] Configure redirect URIs
- [ ] Note authorization and token endpoints
- [ ] Review required and available scopes

### Implementation

- [ ] Generate and store PKCE code verifier
- [ ] Generate state parameter for CSRF protection
- [ ] Build authorization URL with all required parameters
- [ ] Handle callback with error checking
- [ ] Validate state parameter
- [ ] Exchange code for tokens with PKCE verifier
- [ ] Store tokens securely (access in memory, refresh in HTTP-only cookie)
- [ ] Implement automatic token refresh
- [ ] Handle token expiration gracefully
- [ ] Implement logout (local + provider if needed)

### Security Review

- [ ] HTTPS everywhere
- [ ] No tokens in logs
- [ ] No tokens in URLs
- [ ] State validation implemented
- [ ] PKCE implemented for public clients
- [ ] Redirect URI validation
- [ ] Token expiration handling
- [ ] Secure storage

### Testing

- [ ] Successful login flow
- [ ] Token refresh works
- [ ] Logout works
- [ ] Error handling (denied consent, network errors)
- [ ] Session expiration handling
- [ ] Multiple tabs handling
- [ ] Back button handling

---

## Provider Examples

### Google

```javascript
const googleConfig = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
  userInfoEndpoint: 'https://www.googleapis.com/oauth2/v3/userinfo',
  scopes: ['openid', 'profile', 'email'],
  // Additional parameters
  additionalParams: {
    access_type: 'offline',  // Get refresh token
    prompt: 'consent'        // Force consent screen
  }
};
```

### GitHub

```javascript
const githubConfig = {
  authorizationEndpoint: 'https://github.com/login/oauth/authorize',
  tokenEndpoint: 'https://github.com/login/oauth/access_token',
  userInfoEndpoint: 'https://api.github.com/user',
  scopes: ['read:user', 'user:email']
};
```

### Microsoft / Azure AD

```javascript
const microsoftConfig = {
  authorizationEndpoint: 'https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize',
  tokenEndpoint: 'https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token',
  scopes: ['openid', 'profile', 'email', 'offline_access']
};
```

### Auth0

```javascript
const auth0Config = {
  authorizationEndpoint: 'https://{domain}/authorize',
  tokenEndpoint: 'https://{domain}/oauth/token',
  userInfoEndpoint: 'https://{domain}/userinfo',
  scopes: ['openid', 'profile', 'email', 'offline_access'],
  additionalParams: {
    audience: 'https://api.example.com'  // API identifier
  }
};
```

---

**Last Updated**: 2024-01-15  
**Maintainer**: FlashFusion Team
