# Security controls and open gates

## Implemented foundation

- Phoenix socket connections require a token accepted by the canonical Python API's authenticated `GET /auth/verify` endpoint.
- The gateway delegates token signature, signing-key rotation, required-claim, session, revocation, account-state and authorization-version checks to the canonical API rather than maintaining a second JWT trust configuration.
- Identity-validation errors fail closed: rejected credentials do not connect, and API/network/configuration failures do not fall back to local JWT verification.
- Only backend-returned user and tenant identity are assigned to the socket; client-supplied tenant parameters are not trusted as identity.
- The Phase 3 tenant channel permits only `tenant:<tenant_id>:transactions` when the requested tenant exactly matches the verified backend tenant and the verified permissions include `read:transactions`.
- Unsupported topics, missing/malformed claims, malformed tenant identifiers, missing permissions and cross-tenant joins are denied by default.
- Socket handshake rate limits are implemented per peer IP, and channel join limits per authenticated subject, using a bounded, periodically cleaned ETS table. Limits are node-local; production multi-instance deployments also require edge-level controls.
- Production runtime requires explicit exact HTTPS origins and rejects wildcard/path/query/fragment entries. Render configuration specifies `https://app.pesaguard.co.ke`.
- Connected sockets are revalidated against the canonical API every 60 seconds. Changed identity/permissions, invalid credentials or verifier unavailability cause a subject-scoped disconnect.
- Denial logs contain only a reason; they do not include tokens, tenant/user IDs, claims, join params or payloads.
- Internal event endpoint has a separate configured bearer token and constant-time comparison.
- Event envelopes are structurally validated before broadcast.
- Liveness is separate from readiness.

## Authentication and authorization status

The gateway's configured HTTPS validation client calls the canonical API's existing `GET /auth/verify` route. The route in `pesaguard_backend_pipeline/app_3_features.py` uses `@require_auth()` and returns `user_id`, `tenant_id`, `roles`, and `permissions`. The backend remains authoritative for HS256, `kid` key rotation, session/revocation state and account/authorization checks.

Phase 3 authorization, tests, origin validation, rate limiting and socket revalidation are committed on the `phase-3-tenant-authorization` branch. **Formatting, compilation, tests and CI are not yet verified.** See [Phase 3 checklist](phase-3-checklist.md), [authentication integration contract](authentication.md), and [Phase 2 checklist](phase-2-checklist.md).

The canonical identity response does not currently establish arbitrary multi-tenant membership. This implementation deliberately supports only the single tenant in the verified response; it does not infer access from role names or add a cross-tenant override.

## Production gates

- Do not route production dashboard traffic through this gateway until Phase 2 and Phase 3 verification evidence is complete.
- Confirm Render has applied the origin configuration and verify the live endpoint rejects untrusted browser origins.
- Keep edge-level connection and join controls enabled in front of every gateway instance; the in-process rate limiter is not distributed.
- Revalidation runs every 60 seconds, so revocation is not instantaneous. Review its load characteristics before production scale.
- Keep event consumption and broadcast disabled unless the actual producer contract, event schema, topic configuration and tenant routing rules have been verified.
- Missing authentication, authorization, required configuration, or authoritative dependency state must fail closed.
- Never log bearer tokens, raw JWTs, secrets, or unnecessary financial payloads. Reverse-proxy/access logs must redact socket query parameters while tokens are passed through the socket parameter.
- The Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions, and financial state. The gateway is transport-only and must never initiate, confirm, refund, settle, or move funds.
