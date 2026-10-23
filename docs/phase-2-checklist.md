# Phase 2 checklist — Authentication and identity

**Status: IMPLEMENTED, VERIFICATION PENDING; production gate remains closed.**

## Canonical backend contract

- [x] Inspected `pesaguard_backend_pipeline/auth_rbac.py`: HS256, configurable issuer/audience, `kid` key rotation, short-lived access tokens and required claims.
- [x] Inspected the existing `GET /auth/verify` route in `pesaguard_backend_pipeline/app_3_features.py`. It uses `@require_auth()` and returns authenticated user ID, tenant ID, roles and permissions after backend token validation.
- [x] Chose server-side validation rather than duplicating JWT key management or connecting the gateway directly to the private database.

## Gateway implementation

- [x] Added a Finch HTTP client for canonical backend token validation with bounded request timeouts.
- [x] Gateway token verifier delegates validation to the canonical API; it does not trust decoded client claims.
- [x] Only non-empty `user_id` and `tenant_id` from the authoritative API response become socket identity claims.
- [x] Invalid token responses reject the connection; validation-service failures fail closed.
- [x] Production runtime requires `PESAGUARD_AUTH_VALIDATION_URL`; Render configuration points to the canonical `/auth/verify` route.
- [x] Removed duplicated gateway JWT secret/issuer/audience configuration to avoid split key management.
- [x] Added verifier tests for accepted identity, invalid token, backend outage, oversized token and invalid input.
- [x] Internal event-ingest bearer authentication remains separate from dashboard-user identity.

## Remaining acceptance gates

- [ ] Run `mix format --check-formatted`, `mix compile --warnings-as-errors`, and `mix test` in a real Elixir environment.
- [ ] Verify the actual GitHub Actions run and record its URL/status.
- [ ] Confirm production uses HTTPS and reverse-proxy logs redact socket query parameters; consider one-time socket tickets.
- [ ] Define bounded revalidation/forced disconnect for already-connected sockets after session revocation.
- [ ] Confirm canonical `/auth/verify` is reachable from the deployed gateway service and its response shape matches the implemented client.
- [ ] Tenant channel joins remain denied until Phase 3 authorization is implemented.

## Release decision

Phase 2 code integration is implemented but **not verified complete** because tests/compile/CI have not been run from this environment. Production dashboard traffic must remain disabled until those checks pass and the open operational gates are reviewed. Do not begin Phase 3 automatically.

## Verification record

GitHub file commits succeeded. No Elixir commands, Docker build, deployment, or CI run were executed by this change; no successful test/build claim is made.
