# Security controls and open gates

## Implemented foundation

- Phoenix socket connections require a token accepted by the canonical Python API's authenticated `GET /auth/verify` endpoint.
- The gateway delegates token signature, signing-key rotation, required-claim, session, revocation, account-state and authorization-version checks to the canonical API rather than maintaining a second JWT trust configuration.
- Identity-validation errors fail closed: rejected credentials do not connect, and API/network/configuration failures do not fall back to local JWT verification.
- Only backend-returned user and tenant identity are assigned to the socket; client-supplied tenant parameters are not trusted as identity.
- Tenant channel joins remain denied until Phase 3 authorization is implemented.
- Internal event endpoint has a separate configured bearer token and constant-time comparison.
- Event envelopes are structurally validated before broadcast.
- Liveness is separate from readiness.

## Authentication integration status

The gateway's configured HTTPS validation client calls the canonical API's existing `GET /auth/verify` route. The route in `pesaguard_backend_pipeline/app_3_features.py` uses `@require_auth()` and returns `user_id`, `tenant_id`, `roles`, and `permissions`. The backend remains authoritative for HS256, `kid` key rotation, session/revocation state and account/authorization checks.

The code integration is implemented, but Phase 2 is **not verified complete** until Elixir formatting, compilation, tests and GitHub Actions have recorded successful results. Active sockets are not automatically disconnected on later token revocation; that remains a release limitation. See [authentication integration contract](authentication.md) and [Phase 2 checklist](phase-2-checklist.md).

## Production gates

- Do not route production dashboard traffic through this gateway until Phase 2 verification is complete and the active-socket revocation strategy is reviewed.
- Keep tenant channel joins denied until Phase 3 tenant membership authorization is complete.
- Keep event consumption and broadcast disabled unless the actual producer contract, event schema, topic configuration and tenant routing rules have been verified.
- Missing authentication, authorization, required configuration, or authoritative dependency state must fail closed.
- Never log bearer tokens, raw JWTs, secrets, or unnecessary financial payloads. Reverse-proxy/access logs must redact socket query parameters while tokens are passed through the socket parameter.
- The Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions, and financial state. The gateway is transport-only and must never initiate, confirm, refund, settle, or move funds.
