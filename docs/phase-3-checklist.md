# Phase 3 — Tenant authorization checklist

**Status: IMPLEMENTATION COMMITTED TO FEATURE BRANCH; VERIFICATION PENDING.**
This is not a release approval. The current branch has not yet passed a verified format, compile, test and CI run.

## Implemented in this branch

- [x] Socket authentication assigns only identity fields returned by the canonical `GET /auth/verify` endpoint.
- [x] The tenant channel accepts only the exact `tenant:<tenant_id>:transactions` topic shape.
- [x] Requested tenant must exactly match the backend-validated `tenant_id`.
- [x] The verified permission list must be a list of strings containing `read:transactions`.
- [x] Missing/malformed claims, malformed tenant IDs, unsupported topics and tenant mismatches fail closed.
- [x] Client join params cannot override the verified tenant or permissions.
- [x] Denial logs include only a reason code; tokens, identities, join params and payloads are not logged.
- [x] Socket handshake rate limiting is implemented per peer IP: 30 attempts per 60-second window.
- [x] Channel join rate limiting is implemented per authenticated subject: 60 attempts per 60-second window, avoiding reliance on forwarded client IP headers.
- [x] The socket limits channels per transport and the limiter uses a bounded, periodically cleaned ETS table.
- [x] Production runtime rejects missing origin configuration, non-HTTPS origins, wildcard origins and entries containing paths or query/fragment components.
- [x] Render configuration explicitly allows the PesaGuard dashboard origin `https://app.pesaguard.co.ke`.
- [x] Connected sockets are revalidated against the canonical API every 60 seconds. Invalid, changed, or unavailable identity validation disconnects the subject-scoped socket.
- [x] The monitor caps tracked live socket sessions at 10,000 per node and rejects additional registrations when full.
- [x] Socket session tracking is cleaned up when the connection process exits; tokens are held in memory only and never logged.
- [x] Regression tests cover tenant authorization and rate-limiter behavior.
- [x] Event ingestion is explicitly disabled by default; a bearer token alone cannot activate broadcast delivery before Phase 4 approval.
- [x] No event consumer, new event contract, or financial operation was introduced.

## Verification still required

- [ ] Run `mix format --check-formatted`.
- [ ] Run `mix compile --warnings-as-errors`.
- [ ] Run `mix test` and verify the configured coverage threshold.
- [ ] Obtain a successful GitHub Actions run for the latest branch commit. Run `40012248132` for `7eb1bb7` failed in both jobs within about two seconds with no reported steps (`runner_id: 0`); logs were unavailable. The cause is unconfirmed and no passing result is claimed.
- [ ] Verify Render has actually applied the `render.yaml` origin value and that the live Phoenix endpoint rejects disallowed browser origins.
- [ ] Verify connection limits at the public proxy/load balancer. The in-process limiter is node-local, so multi-instance deployments need edge-level controls too.
- [ ] Review the revalidation interval and capacity against expected concurrent socket volume.
- [ ] Confirm canonical tenant IDs follow the accepted identifier format.
- [ ] Complete a security review of every socket declaration and every tenant-topic selection path.
- [ ] Keep `PESAGUARD_EVENT_INGEST_ENABLED=false` until Phase 4 contract, producer identity, tenant derivation, and delivery semantics are reviewed and tested.

## Trust model and limitations

The canonical `GET /auth/verify` contract returns the authenticated user's current `tenant_id`, roles and permissions, but it does not provide a complete membership lookup for arbitrary tenants. This implementation intentionally authorizes only the single tenant in the verified response. It does not infer cross-tenant access from a role name and does not add a cross-tenant override.

The session monitor compares the refreshed identity and permissions with the claims captured at connection time. It disconnects the subject-scoped socket when those claims change or the verifier is unavailable. The check runs every 60 seconds; revocation is therefore not instantaneous, and the monitor must be load-tested before high-volume production use.

The rate limiter is process-local and not a substitute for edge-level protection or a distributed quota service. The only supported subscription is transaction read access. Other resource topics must not be enabled until their permissions and event contracts are agreed and tested.

The Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions and financial state. The gateway is transport-only and must never initiate, confirm, refund, move or settle payments.

## Release gate

Keep production dashboard traffic off this gateway until Phase 2 and Phase 3 compile/test/CI evidence is recorded, live origin enforcement is confirmed, and operational limits are reviewed. Do not proceed to Phase 4 until the exit gate is satisfied.
