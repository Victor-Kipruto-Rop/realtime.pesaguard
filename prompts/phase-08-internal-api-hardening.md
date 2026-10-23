# Phase 08 Prompt — Internal API, Operational Endpoints and Abuse Controls

## Mission
Harden internal event-ingestion and operational HTTP surfaces against unauthorized use, malformed input, replay and resource abuse.

## Mandatory context
Read universal prompt rules, router/controllers/plugs, event contract, auth design, and security, API-design, testing and incident-response skills.

## Execute
1. Inventory every HTTP route, including internal event ingestion, health, readiness, metrics and any debug endpoints. Document exposure and intended callers.
2. Authenticate internal publishers using the confirmed service-to-service contract; scope credentials to required actions and rotate them. Do not treat a browser user token as a publisher credential.
3. Derive tenant context from authenticated service identity and trusted event contracts; do not let arbitrary request fields grant tenant scope.
4. Enforce JSON content type, schema validation, maximum body size, timeouts, rate limits, replay/idempotency protection and safe error responses.
5. Separate liveness from readiness. Liveness should indicate the process can respond; readiness should reflect required dependencies and never expose internal topology or secrets.
6. Configure origin/CORS and secure HTTP headers only for routes where they apply. Avoid exposing metrics or detailed diagnostics publicly without explicit policy.
7. Add tests for missing/invalid credentials, replay, oversized body, malformed schema, unsupported content type, rate limiting, dependency outage and information leakage.

## Scope lock
Do not change the event contract or claim a dependency is healthy without a real check. Avoid building a general public API if the service is intended to be internal.

## Acceptance checklist
- [ ] Every route is inventoried and correctly protected.
- [ ] Publisher authentication and tenant trust are evidence-based.
- [ ] Input, size, rate and replay controls are implemented and tested.
- [ ] Readiness/liveness behavior is accurate.
- [ ] Errors do not leak secrets, stack traces or private topology.
- [ ] Security tests and docs reflect actual route behavior.

## Required closeout
Update route/security documentation and Phase 08 checklist. Do not proceed to rollout until internal endpoints are hardened.

## Follow-up prompt
“Perform an abuse-oriented review of every HTTP endpoint. Try missing credentials, replay, oversized/malformed bodies, tenant spoofing and diagnostic leakage; add regression tests and fix only API-hardening defects.”
