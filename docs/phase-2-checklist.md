# Phase 2 checklist — Authentication and identity

**Status: BLOCKED — implementation is only partially compatible with the canonical issuer.**

## Verified from canonical backend source

Source inspected: `Victor-Kipruto-Rop/api.pesaguard/pesaguard_backend_pipeline/auth_rbac.py`.

- [x] Confirmed HS256 as the issuer algorithm.
- [x] Confirmed default issuer `pesaguard` and audience `pesaguard-api`, both configurable in the backend.
- [x] Confirmed signing key selection uses `JWT_SECRET_KEY` or `JWT_KEYS_JSON`, with active `JWT_ACTIVE_KID` and JWT header `kid`.
- [x] Confirmed required access-token claims include `exp`, `iat`, `nbf`, `jti`, `sub`, `tenant_id`, `type`, `iss`, `aud`, `auth_version`, and `scope`.
- [x] Confirmed access token TTL is limited to 1–15 minutes and backend authentication checks persisted session and account/authorization state.

## Gateway implementation already present

- [x] Fail-closed HS256 verifier using Joken.
- [x] Issuer/audience, expiry, optional not-before, and non-empty `sub` / `tenant_id` checks.
- [x] Phoenix socket connection authenticates using the verifier and assigns verified claims only.
- [x] Missing verifier configuration rejects socket connections.
- [x] Tenant channel joins remain denied pending Phase 3 authorization.
- [x] Unit tests exist for locally signed valid/malformed/wrong-secret/missing-config/missing-tenant/expired/future-`nbf` tokens.
- [x] Documentation records the canonical issuer contract and outstanding incompatibilities.

## Required — not yet satisfied

- [ ] Implement the issuer's `kid`-based configured signing-key map and key rotation behavior.
- [ ] Require and validate all canonical access-token claims, including `type == "access"`, `iat`, `nbf`, `jti`, `auth_version`, and `scope`.
- [ ] Establish an approved backend validation/introspection API for current session, token revocation, account status and authorization version. The gateway must not directly access the backend's private database.
- [ ] Define how human user tokens differ from service/API-client tokens and what gateway principal types are allowed.
- [ ] Add issuer-compatible contract tests, including active/previous key rotation and unknown `kid`.
- [ ] Add negative tests for wrong issuer, wrong audience, unsupported algorithm, missing canonical claims, invalid token type, revoked session/account, stale authorization version, and validation-service outage.
- [ ] Review WebSocket credential transport and ensure access/query logs redact token-bearing parameters; implement one-time socket tickets if required by the approved auth flow.
- [ ] Run `mix format --check-formatted`, `mix compile --warnings-as-errors`, and `mix test` in an Elixir environment.
- [ ] Verify the actual GitHub Actions run and record its URL/status.

## Release gate

Do not mark Phase 2 complete until every required item is evidenced. If the canonical backend has no supported session/revocation validation API, Phase 2 remains blocked until an approved contract is created. Do not implement an undocumented endpoint by assumption.

Tenant channel joins must remain denied until Phase 3 authorization passes its own acceptance gate. No production dashboard traffic may be routed through the gateway while this phase is blocked.

## Verification record

No Elixir commands were run as part of this documentation update. No test, compile, Docker build, or CI result is claimed here.
