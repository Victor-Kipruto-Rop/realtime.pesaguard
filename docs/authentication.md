# Authentication integration contract

## Canonical issuer evidence

The canonical API repository `Victor-Kipruto-Rop/api.pesaguard`, file `pesaguard_backend_pipeline/auth_rbac.py`, defines the current access-token contract. The gateway must follow this issuer rather than require the issuer to change to match a gateway-specific assumption.

Verified from that source:

- Algorithm: HS256.
- Issuer default: `pesaguard`, configurable with `JWT_ISSUER`.
- Audience default: `pesaguard-api`, configurable with `JWT_AUDIENCE`.
- Signing key: `JWT_SECRET_KEY`, or key map `JWT_KEYS_JSON`; active key selected by `JWT_ACTIVE_KID`.
- Signed JWT header includes `kid`; verification chooses a configured key and rejects unknown key IDs.
- Access-token lifetime is configured from 1 to 15 minutes (default 15).
- Required claims include `exp`, `iat`, `nbf`, `jti`, `sub`, `tenant_id`, `type`, `iss`, `aud`, `auth_version`, and `scope`.
- Issued access tokens use `type: "access"`; the backend also issues machine-principal tokens with `principal_type`, `principal_id`, and permissions/scopes.
- Backend auth includes persisted session activity/expiry checks, revoked-token state, and current account/authorization-version checks. These are not represented by signature verification alone.

The backend source also shows a 30-second JWT clock leeway. The gateway must not silently widen expiry windows beyond the issuer's documented policy.

## Gateway implementation currently present

The gateway has a fail-closed Joken HS256 verifier invoked by the Phoenix socket connection. It currently validates the configured issuer/audience, expiration, optional not-before, and non-empty `sub` and `tenant_id`. It returns a limited claim set and rejects connections if required verifier configuration is missing.

**This verifier is not yet contract-compatible with the full canonical issuer contract.** In particular, it does not yet implement the issuer's `kid` key selection/rotation model or require all canonical claims, and it does not check persisted session, token revocation, account status, or `auth_version` against authoritative backend state. The existing local test signer only proves behavior against itself, not interoperability with the backend.

## Required completion work

1. Implement configured key-map verification compatible with `JWT_KEYS_JSON` and `JWT_ACTIVE_KID`. Pin the algorithm to HS256; never trust an unverified header to select an algorithm, and allow a `kid` only to select among explicitly configured keys.
2. Require and validate all applicable canonical access-token claims, including `type == "access"`, `jti`, `iat`, `nbf`, `auth_version`, and `scope`, with bounded claim sizes and the issuer's clock policy.
3. Establish a documented server-to-server contract with the canonical backend for checking current session, revocation, account state and authorization version. Do not query the backend's private database directly from this gateway. If no supported validation/introspection endpoint exists, record this as a release blocker and keep user sockets unavailable for production.
4. Separate human-user access tokens from service/API-client tokens and internal event-publisher credentials. Do not treat the internal event-ingest bearer token as a dashboard identity token.
5. Add contract tests using tokens issued by the canonical backend (including key rotation and rejected unknown `kid`) and negative tests for wrong issuer/audience, missing claims, unsupported algorithms, expiry, revoked/inactive session and unavailable validation service.
6. Confirm browser WebSocket token transport and reverse-proxy log redaction. Use short-lived tokens; if tokens must not appear in connection URLs/logs, add a one-time short-lived ticket exchange through the canonical backend.
7. Run the Elixir formatter, compile, tests, and actual GitHub Actions checks; record the evidence in the checklist.

## Current environment configuration

The existing gateway configuration uses `PESAGUARD_JWT_HS256_SECRET`, `PESAGUARD_JWT_ISSUER`, and `PESAGUARD_JWT_AUDIENCE`. These settings are **not yet a complete representation** of the backend's key-rotation and stateful-validation contract. Do not populate them with production values or route production traffic until the adapter and validation boundary above are implemented and verified.

## Fail-closed behavior

- Missing or malformed verifier configuration rejects socket connections.
- Tenant channel joins remain denied until Phase 3 tenant membership authorization is implemented.
- If the canonical session/revocation validation service is unavailable, the gateway must reject new connections rather than accept stale tokens.
- No gateway feature may originate, confirm, refund, settle, or move funds. The Python backend remains authoritative for financial state.
