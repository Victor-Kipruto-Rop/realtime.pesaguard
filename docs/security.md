# Security controls and open gates

## Implemented foundation
- Phoenix socket connections require a verified JWT; malformed, invalid-signature, expired and not-yet-valid tokens are rejected.
- JWT validation fails closed when the verifier settings are absent.
- Verified claims are assigned to the socket; raw, unverified client tenant parameters are not treated as identity.
- Tenant channel joins remain denied until Phase 3 authorization is implemented.
- Internal event endpoint has a separate configured bearer token and constant-time comparison.
- Event envelopes are structurally validated before broadcast.
- Liveness is separate from readiness.

## Authentication configuration warning
The current adapter supports HS256 only. It is not production identity integration until the canonical PesaGuard issuer's algorithm, key-management model, issuer, audience, claim schema, tenant membership semantics and revocation behavior are verified. Do not set gateway secrets by guessing. If the canonical issuer uses asymmetric JWTs/JWKS or opaque tokens, implement that real contract instead. The local test signer is not an issuer interoperability test.

## Required before production
1. Confirm the canonical identity contract and exercise it with issuer-generated test credentials.
2. Complete Phase 3 membership and per-channel authorization; channel joins currently fail closed.
3. Add internal service-token rotation/scoping and request replay/idempotency protection.
4. Add payload allow-lists per event type, request body-size limits, rate limiting, origin allow-list, and redaction.
5. Never broadcast raw statements, full account numbers, phone numbers, access tokens, PINs, or identity-document data.
6. Audit authorization failures without logging secrets or tokens.
7. Configure TLS, secret management, dependency monitoring, and cross-tenant/load tests.
8. Verify the actual build, tests, and CI in a real Elixir/Docker environment.

Readiness intentionally remains 503 because the event-bus consumer is not implemented. Successful JWT validation alone does not make the gateway ready for production traffic.
