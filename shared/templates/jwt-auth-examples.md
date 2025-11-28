# JWT Authentication Best Practices & Examples

Key concepts:
- Use short-lived access tokens (e.g., 15m) and long-lived refresh tokens stored securely.
- Sign tokens with strong HMAC (HS256) or preferably with RSA/ECDSA asymmetric keys (RS256/ES256).
- Rotate refresh tokens on use to prevent reuse (one-time rotation).
- Never store secrets in source code.

## Example: Express middleware verifying RS256 JWT

```js
const jwt = require('jsonwebtoken');
const fs = require('fs');
const publicKey = fs.readFileSync('./keys/public.pem');

function verifyToken(req, res, next) {
  const token = (req.headers.authorization || '').split(' ')[1];
  if(!token) return res.status(401).send('Missing token');
  jwt.verify(token, publicKey, { algorithms: ['RS256'] }, (err, payload) => {
    if(err) return res.status(401).send('Invalid token');
    req.user = payload;
    next();
  });
}
```

## Token Storage Recommendations

- **Web app (SPA)**: store access token in memory, refresh token in httpOnly secure cookie.
- **Mobile**: use platform secure storage (Keychain / Keystore).
- **Server-to-server**: prefer mTLS or short-lived tokens issued by OAuth2 client credentials.

## Revocation Strategies

- Keep a short access token lifetime and validate refresh tokens with server DB.
- Maintain a token blacklist only for emergency revocation.

## Standard Claims

| Claim | Description |
|-------|-------------|
| `sub` | Subject - unique user ID |
| `aud` | Audience - your API identifier |
| `iss` | Issuer - token issuer |
| `exp` | Expiry timestamp |
| `iat` | Issued at timestamp |

## Key Rotation

- Support key ids (`kid`) in JWT header
- Keep multiple keys to allow rotation without downtime
- Implement key rotation schedule (e.g., every 90 days)

## Security Checklist

- [ ] Use HTTPS everywhere
- [ ] Set appropriate token expiry times
- [ ] Validate token signature algorithm
- [ ] Check `iss` and `aud` claims
- [ ] Implement refresh token rotation
- [ ] Store secrets in environment variables or secret managers
- [ ] Use asymmetric keys for production
