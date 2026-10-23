# Authentication integration contract

## Canonical validation

The gateway delegates authentication to the canonical Python API's existing `GET /auth/verify` endpoint. That route is decorated with the backend's `require_auth()` middleware and returns authenticated `user_id`, `tenant_id`, roles and permissions only after backend token validation. The canonical implementation in `pesaguard_backend_pipeline/auth_rbac.py` owns HS256 verification, `kid`-based key rotation, required claims, token revocation, persisted session lifecycle, account status and authorization-version checks.

Gateway flow:

1. The browser supplies a short-lived bearer access token over the Phoenix socket's `token` parameter using WSS.
2. The gateway sends the token to the configured canonical `PESAGUARD_AUTH_VALIDATION_URL` over HTTP with bounded connect/pool and response timeouts.
3. A 200 response must contain non-empty `user_id` and `tenant_id`; only those authoritative response fields and bounded roles/permissions are assigned to the socket.
4. A 401/403 rejects the connection. Network errors, malformed responses, timeouts and 5xx responses fail closed as identity-validation unavailable.
5. The gateway does not independently manage JWT signing keys or decode unverified claims. The backend remains the source of truth for token and account state.

## Configuration

Set `PESAGUARD_AUTH_VALIDATION_URL` to the canonical API's `/auth/verify` endpoint. Production runtime requires this setting. Use HTTPS in production. The gateway no longer needs a copy of `JWT_SECRET_KEY` or `JWT_KEYS_JSON`; key rotation remains exclusively controlled by the backend.

The canonical endpoint response is not cached. This means a connection attempt depends on the API being reachable and authentication state being available. This is intentional fail-closed behavior. Keep request timeouts bounded and do not log authorization headers, tokens, or response bodies.

## Known limitations and release gates

- The canonical endpoint validates the token at connection time; it does not automatically terminate an already-connected socket when a session is revoked. A bounded revalidation/forced-disconnect strategy is required before relying on immediate revocation for long-lived sockets.
- The current gateway socket still accepts the token as a socket parameter. WSS and reverse-proxy/access-log redaction of query strings are required. A one-time socket-ticket exchange is preferable if supported by the canonical backend.
- Tenant channel joins remain denied until Phase 3 implements authoritative tenant membership authorization. The authenticated `tenant_id` alone is not proof the user may join every requested tenant channel.
- Service/API-client principals should not be admitted to dashboard sockets unless a separate explicit policy is approved.

No production traffic should be routed until Phase 2's real Elixir checks and CI evidence are recorded and the open gates above are resolved.
