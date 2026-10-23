# Security controls and open gates

## Implemented foundation
- WebSocket connections deny by default.
- Tenant channel joins deny by default.
- Internal event endpoint requires a configured bearer token and constant-time comparison.
- Event envelopes are structurally validated before broadcast.
- Liveness is separate from readiness.

## Required before production
1. Implement token verification against the canonical PesaGuard issuer, including signature, issuer, audience, expiry, and tenant/role claims. Do not trust a tenant ID supplied in query params.
2. After authentication, store verified claims in socket assigns and permit joining only the tenant authorized by those claims.
3. Use a short-lived service credential or signed request for internal events, scoped to publish-only and rotated regularly.
4. Add payload allow-lists per event type, size limits, rate limiting, origin allow-list, and redaction.
5. Never broadcast raw statements, full account numbers, phone numbers, access tokens, PINs, or identity-document data.
6. Audit authorization failures without logging secrets.
7. Configure TLS, secret management, dependency monitoring, and cross-tenant/load tests.

Readiness intentionally returns 503 until the auth verifier and event bus consumer are implemented.