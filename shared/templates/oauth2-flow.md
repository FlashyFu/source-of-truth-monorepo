# OAuth2 Flow Reference

OAuth2 Authorization Code Flow (recommended for web apps) with PKCE (for public clients).

## Authorization Code Flow

### 1. Client Redirects to Authorization Server

```
GET /authorize?
  response_type=code
  &client_id=...
  &redirect_uri=...
  &code_challenge=...
  &code_challenge_method=S256
  &state=...
  &scope=openid profile email
```

### 2. User Authenticates and Authorizes Client

User logs in and grants permissions to the client application.

### 3. Authorization Server Redirects Back with Code

```
GET /callback?
  code=AUTHORIZATION_CODE
  &state=ORIGINAL_STATE
```

### 4. Client Exchanges Code for Tokens

```http
POST /token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=AUTHORIZATION_CODE
&redirect_uri=https://client.example.com/callback
&client_id=CLIENT_ID
&code_verifier=ORIGINAL_CODE_VERIFIER
```

### 5. Token Response

```json
{
  "access_token": "eyJhbGciOi...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpc...",
  "scope": "openid profile email"
}
```

## PKCE (Proof Key for Code Exchange)

Public clients (SPAs/native apps) should use PKCE to mitigate authorization code interception.

### Generate Code Verifier

```javascript
// Generate a random code_verifier (43-128 characters)
const codeVerifier = generateRandomString(64);
```

### Generate Code Challenge

```javascript
// code_challenge = BASE64URL(SHA256(code_verifier))
const codeChallenge = base64url(sha256(codeVerifier));
```

## Client Credentials Grant

For server-to-server communication without user involvement:

```http
POST /token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=CLIENT_ID
&client_secret=CLIENT_SECRET
&scope=api:read api:write
```

## Refresh Token Grant

```http
POST /token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token=REFRESH_TOKEN
&client_id=CLIENT_ID
```

## Security Checklist

- [ ] Use HTTPS everywhere
- [ ] Validate `state` parameter to prevent CSRF
- [ ] Use short-lived access tokens
- [ ] Store refresh tokens securely
- [ ] Implement PKCE for public clients
- [ ] Validate redirect URIs strictly
- [ ] Follow OAuth 2.0 for Browser-Based Apps recommendations
- [ ] Consider OAuth 2.1 recommendations

## OpenID Connect

Use OIDC when identity claims (id_token) are required:

```
GET /authorize?
  response_type=code
  &client_id=...
  &redirect_uri=...
  &scope=openid profile email
  &nonce=RANDOM_NONCE
```

The `id_token` contains user identity information:

```json
{
  "iss": "https://auth.example.com",
  "sub": "user-123",
  "aud": "client-id",
  "exp": 1699999999,
  "iat": 1699996399,
  "nonce": "RANDOM_NONCE",
  "name": "John Doe",
  "email": "john@example.com"
}
```

## Common Grant Types

| Grant Type | Use Case |
|------------|----------|
| `authorization_code` | Web apps with backend |
| `authorization_code` + PKCE | SPAs and native apps |
| `client_credentials` | Server-to-server |
| `refresh_token` | Token renewal |
| `device_code` | Limited input devices |
