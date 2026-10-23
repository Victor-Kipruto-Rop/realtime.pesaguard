# Authentication integration contract

## Canonical validation

The gateway delegates authentication to the canonical Python API's existing `GET /auth/verify` endpoint. That route is decorated with the backend's `require_auth()` middleware and returns authenticated `user_id`, `tenant_id`, roles and permissions only after backend token validation. The canonical implementation in `pesaguard_backend_pipeline/auth_rbac.py` owns HS256 verification, `kid`-based key rotation, required claims, token revocation, persisted session lifecycle, account status and authorization-version checks.

Gateway flow:

1. The browser supplies a short-lived bearer access token over the Phoenix socket's `token` parameter using WSS.
2. The gateway sends the token to the configured canonical `PESAGUARD_AUTH_VALIDATION_URL` over HTTPS with bounded connect/pool and response timeouts.
3. A 200 response must contain non-empty `user_id` and `tenant_id`; only those authoritative response fields and bounded roles/permissions are assigned to the socket.
4. A 401/403 rejects the connection. Network errors, malformed responses, timeouts and 5xx responses fail closed as identity-validation unavailable.
5. The gateway does not independently manage JWT signing keys or decode unverified JWT claims. The backend remains the source of truth for token and account state.

## Tenant authorization

The channel currently supports only `tenant:<tenant_id>:transactions`. The requested tenant must exactly match the backend-verified `tenant_id`, and the verified `permissions` list must contain `read:transactions`. The topic is parsed strictly; generic tenant topics, other resource names, extra segments, malformed IDs and missing/malformed permissions are denied. Join params cannot override the verified tenant. Denials are logged using a reason code only.

The current `GET /auth/verify` contract does not provide a complete organization-membership lookup for arbitrary tenants. Consequently, the gateway intentionally does not support cross-tenant membership, organization switching within an existing socket, or role-based overrides. Such support requires an explicit canonical membership contract and dedicated tests.

## Origin and abuse controls

Production runtime requires explicit exact HTTPS origins in `PESAGUARD_ALLOWED_ORIGINS`, configures Phoenix `check_origin` with that allow-list, and rejects wildcard or origin entries containing paths, queries or fragments. The Render blueprint sets the dashboard origin to `https://app.pesaguard.co.ke`; confirm the blueprint has been applied to the live service.

Socket handshakes are limited to 30 per peer IP per 60-second window, and channel joins to 60 per peer IP per 60-second window. The in-process ETS limiter is node-local and is not a distributed quota system; production multi-instance deployments must also enforce edge-level limits. Each socket is limited to five channels per transport.

## Connected-session revalidation

The gateway stores each live connection's access token in the in-memory session monitor only; tokens are never logged or sent to clients in responses. Every 60 seconds the monitor asks the canonical API to validate the token again and compares the refreshed identity and permission claims with the connection's original claims. Invalid credentials, changed claims, timeouts, or verifier unavailability cause a subject-scoped disconnect. Process monitors remove records when socket connection processes exit.

This is bounded periodic revocation handling, not instantaneous revocation: a change may remain effective on an existing connection for up to the revalidation interval, plus processing delay. The monitor's capacity and behavior under load must be verified before production-scale rollout.

## Configuration

Set `PESAGUARD_AUTH_VALIDATION_URL` to the canonical API's `/auth/verify` endpoint. Production runtime requires this setting and enforces HTTPS. The gateway does not need a copy of `JWT_SECRET_KEY` or `JWT_KEYS_JSON`; key rotation remains exclusively controlled by the backend.

The canonical endpoint response is not cached. This means a connection attempt depends on the API being reachable and authentication state being available. This is intentional fail-closed behavior. Keep request timeouts bounded and do not log authorization headers, tokens, or response bodies.

## Remaining verification and release gates

- Run formatting, compilation and tests in a real Elixir environment and inspect the latest GitHub Actions result.
- Confirm Render has applied the origin configuration and test that untrusted origins are rejected on the live endpoint.
- Confirm edge-level rate limits are configured for all deployed instances.
- Load-test the 60-second session revalidation process against expected concurrent socket volume.
- Service/API-client principals should not be admitted to dashboard sockets unless a separate explicit policy is approved.
- Keep production dashboard traffic disabled until Phase 2 and Phase 3 verification evidence and operational gates are complete.
