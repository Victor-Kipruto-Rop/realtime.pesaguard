# Authentication integration contract

## Implemented adapter boundary

The gateway now has a fail-closed HS256 JWT verifier and uses it during Phoenix socket connection. A connection is accepted only when the JWT signature and configured issuer/audience are valid, the token is not expired or not-yet-valid, and non-empty `sub` and `tenant_id` claims are present. The socket stores only verified claims. Missing verifier configuration rejects connections.

This is a deliberately narrow adapter, **not proof that the current PesaGuard identity provider issues this token format**. Before configuring it in staging or production, inspect the canonical API/auth implementation and confirm all items below. If PesaGuard uses RS256/ES256, JWKS, opaque tokens, different claims, or server-side membership checks, replace/adapt the verifier to that actual contract; do not change the issuer's behavior to match this gateway.

## Supported configuration

- `PESAGUARD_JWT_HS256_SECRET`: shared HS256 signing secret, minimum 32 bytes.
- `PESAGUARD_JWT_ISSUER`: exact expected `iss` claim.
- `PESAGUARD_JWT_AUDIENCE`: expected `aud` claim.
- Tokens must contain `sub`, `tenant_id`, `iss`, `aud`, and `exp`; `nbf` is validated when present.
- The verifier accepts only HS256. It does not negotiate algorithms from token headers and does not fetch JWKS.

Use the same secret as the canonical issuer only if the issuer contract explicitly uses HS256 and provides a supported secret-sharing model. Never copy a private signing key into this setting. Prefer asymmetric verification/JWKS when that is what the canonical identity system supports.

## Browser socket

The Phoenix socket currently expects a `token` connection parameter over TLS/WSS. Browser WebSocket APIs do not allow arbitrary authorization headers. Therefore use short-lived access tokens, redact query strings from proxy/access logs, avoid token logging/analytics, and rotate credentials. If the frontend's auth flow cannot safely support this, implement a short-lived, one-time WebSocket ticket exchange with the canonical backend before rollout.

## Still required before production

- Confirm issuer, audience, signing algorithm, key distribution/rotation, token lifetime, revocation/logout policy and exact claim schema against the canonical backend.
- Confirm whether tenant membership is represented by a trusted claim or must be fetched from an authoritative membership API. A `tenant_id` claim alone is not sufficient if the issuer does not guarantee current membership.
- Implement token revocation/session invalidation if required by the identity contract.
- Keep tenant channel joins denied until Phase 3 authorization is complete.
- Run the auth test suite in a real Elixir environment and add contract tests using issuer-generated test tokens; the included tests use a local test signer and do not prove interoperability with production tokens.
