# Authentication integration contract

## Canonical validation

The gateway delegates authentication to the canonical Python API's existing `GET /auth/verify` endpoint. That route is decorated with the backend's `require_auth()` middleware and returns authenticated `user_id`, `tenant_id`, roles and permissions only after backend token validation. The canonical implementation in `pesaguard_backend_pipeline/auth_rbac.py` owns HS256 verification, `kid`-based key rotation, required claims, token revocation, persisted session lifecycle, account status and authorization-version checks.

Gateway flow:

1. The browser supplies a short-lived bearer access token over the Phoenix socket's `token` parameter using WSS.
2. The gateway sends the token to the configured canonical `PESAGUARD_AUTH_VALIDATION_URL` over HTTP with bounded connect/pool and response timeouts.
3. A 200 response must contain non-empty `user_id` and `tenant_id`; only those authoritative response fields and bounded roles/permissions are assigned to the socket.
4. A 401/403 rejects the connection. Network errors, malformed responses, timeouts and 5xx responses fail closed as identity-validation unavailable.
5. The gateway does not independently manage JWT signing keys or decode unverified claims. The backend remains the source of truth for token and account state.

## Tenant authorization

The channel currently supports only `tenant:<tenant_id>:transactions`. The requested tenant must exactly match the backend-verified `tenant_id`, and the verified `permissions` list must contain `read:transactions`. The topic is parsed strictly; generic tenant topics, other resource names, extra segments, malformed IDs and missing/malformed permissions are denied. Join params cannot override the verified tenant. Denials are logged using a reason code only.

The current `GET /auth/verify` contract does not provide a complete organization-membership lookup for arbitrary tenants. Consequently, the gateway intentionally does not support cross-tenant membership, organization switching within an existing socket, or role-based overrides. Such support requires an explicit canonical membership contract and dedicated tests. See [Phase 3 checklist](phase-3-checklist.md).

## Configuration

Set `PESAGUARD_AUTH_VALIDATION_URL` to the canonical API's `/auth/verify` endpoint. Production runtime requires this setting. Use HTTPS in production. The gateway no longer needs a copy of `JWT_SECRET_KEY` or `JWT_KEYS_JSON`; key rotation remains exclusively controlled by the backend.

The canonical endpoint response is not cached. This means a connection attempt depends on the API being reachable and authentication state being available. This is intentional fail-closed behavior. Keep request timeouts bounded and do not log authorization headers, tokens, or response bodies.

## Known limitations and release gates

- The canonical endpoint validates the token at connection time; it does not automatically terminate an already-connected socket when a session is revoked. A bounded revalidation/forced-disconnect strategy is required before relying on immediate revocation for long-lived sockets.
- The current gateway socket still accepts the token as a socket parameter. WSS and reverse-proxy/access-log redaction of query strings are required. A one-time socket-ticket exchange is preferable if supported by the canonical backend.
- Confirm production origin enforcement against the configured `PESAGUARD_ALLOWED_ORIGINS` allow-list and add/verify connection and join rate limits.
- Service/API-client principals should not be admitted to dashboard sockets unless a separate explicit policy is approved.
- Elixir formatting, compilation, tests and CI evidence remain required before Phase 2/3 can pass their exit gates.

No production traffic should be routed until the phase checklists' verification evidence and open security gates are resolved.
