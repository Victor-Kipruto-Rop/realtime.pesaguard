# Security controls and open gates

## Implemented foundation

- Phoenix socket connections require a verified JWT; malformed, invalid-signature, expired and not-yet-valid tokens are rejected.
- JWT validation fails closed when verifier settings are absent.
- Verified claims are assigned to the socket; raw, unverified client tenant parameters are not treated as identity.
- Tenant channel joins remain denied until Phase 3 authorization is implemented.
- Internal event endpoint has a separate configured bearer token and constant-time comparison.
- Event envelopes are structurally validated before broadcast.
- Liveness is separate from readiness.

## Authentication contract status

The canonical API's `pesaguard_backend_pipeline/auth_rbac.py` uses HS256, configurable issuer/audience (defaults `pesaguard` / `pesaguard-api`), a `kid`-selected signing-key map, short-lived access tokens, and required identity/lifecycle claims. It also validates persisted session and account/authorization state.

The gateway verifier currently does not fully implement key rotation, all required claims, or authoritative session/revocation/account-state checks. Therefore the current adapter is **not production-ready identity integration**. See [authentication integration contract](authentication.md) and [Phase 2 checklist](phase-2-checklist.md).

## Production gates

- Do not route production dashboard traffic through this gateway until Phase 2 is complete and verified.
- Keep tenant channel joins denied until Phase 3 tenant membership authorization is complete.
- Keep event consumption and broadcast disabled unless the actual producer contract, event schema, topic configuration and tenant routing rules have been verified.
- Missing authentication, authorization, required configuration, or authoritative dependency state must fail closed.
- Never log bearer tokens, raw JWTs, secrets, or unnecessary financial payloads.
- The Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions, and financial state. The gateway is transport-only and must never initiate, confirm, refund, settle, or move funds.
