# Phase 4 — Event contract checklist

**Status: IMPLEMENTATION COMMITTED; RELEASE/PRODUCER COMPATIBILITY VERIFICATION PENDING.**

## Implemented
- [x] Inspected the canonical Python event envelope and producer event types in `Victor-Kipruto-Rop/api.pesaguard`.
- [x] Versioned gateway contract requires event version 1 and schema version 1.0.
- [x] Enforces encoded event size limit of 65,536 bytes.
- [x] Validates required identifiers, tenant identifier syntax, and RFC 3339 UTC timestamps.
- [x] Rejects unknown top-level fields, unsupported event types/versions, and non-allow-listed payload fields.
- [x] Normalizes the legacy `timestamp` field to `occurred_at`.
- [x] Reconstructs the browser event from an explicit allow-list; internal producer fields and metadata are not forwarded.
- [x] Initial browser registry allows `fraud.analysis.started`, `transaction.failed`, and `transaction.rejected`, each backed by inspected Python producer code and strict per-event payload schemas.
- [x] Added regression tests for invalid versions, timestamps, tenant IDs, oversized payloads, unknown fields, lifecycle state mismatch, and the checked-in synthetic producer-contract fixture.

## Verification / release gates
- [ ] Run formatter, compile and tests in a working pinned Elixir/OTP environment.
- [ ] Run the checked-in synthetic fixture through the actual Python producer's serializer and compare outputs in an integration test.
- [ ] Agree producer identity and tenant derivation; schema validation alone does not authenticate tenant scope.
- [ ] Add signed/service-authenticated internal publishing and replay protection as part of Phase 8 before enabling ingress.
- [ ] Keep `PESAGUARD_EVENT_INGEST_ENABLED=false` until producer contract, tenant trust, and delivery behavior pass integration tests.
- [ ] Do not claim the Phase 4 exit gate or production event routing is complete until the evidence above is recorded.
