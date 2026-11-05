# Phase 8 — Internal API, operational endpoints and abuse controls

**Status: PARTIAL IMPLEMENTATION — producer identity and durable replay protection remain blockers.**

## Implemented
- [x] Internal event route is disabled by default and returns `503` while disabled.
- [x] Dedicated bearer token uses constant-time comparison.
- [x] Request JSON body is bounded by the endpoint parser configuration.
- [x] Strict versioned event contract is validated before broadcast and revalidated by the broadcaster.
- [x] Node-local fixed-window rate limit is applied to enabled internal ingestion.
- [x] Node-local bounded 10-minute event-ID duplicate suppression rejects same-tenant duplicates and cross-tenant ID collisions.
- [x] Safe error responses do not expose validator internals.
- [x] Liveness is independent of downstream dependencies; readiness remains not-ready until the event consumer and required auth integration are verified.

## Exit gates
- [ ] Replace the static bearer-only publisher trust model with an agreed service identity/signature contract shared with the canonical Python backend.
- [ ] Derive tenant scope from authenticated publisher context; never trust `tenant_id` from the event body alone.
- [ ] Replace node-local deduplication with shared durable idempotency/replay storage before multi-instance or durable-delivery claims.
- [ ] Test authentication failures, replay, cross-tenant event-ID collision, rate limits, malformed/oversized bodies, dependency outage and multi-instance behavior.
- [ ] Confirm trusted proxy configuration before relying on forwarded client IPs for edge/rate controls.
- [ ] Keep ingestion disabled until all publisher identity and tenant-binding tests pass.

Node-local controls are defense in depth only. They are not distributed quotas, durable exactly-once delivery, or proof of publisher tenant authority.
