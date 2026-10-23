# Phase 02 Prompt — Authentication and Identity Integration

## Mission
Authenticate dashboard WebSocket connections and internal service requests using the **actual canonical PesaGuard identity contract**. Authentication is a hard production gate.

## Mandatory context
Read `prompts/README.md`, `docs/authentication.md`, `docs/security.md`, `docs/phase-2-checklist.md`, and the security-hardening, integration, API-design and testing skills. Inspect the current `TokenVerifier`, socket connection handler, internal endpoint authentication and canonical Python backend/auth implementation.

## Execute
1. Discover the real issuer, token format, allowed algorithm, issuer/audience values, signing key/JWKS rotation model, required claims, expiry/not-before rules, tenant membership semantics, revocation/logout behavior and service-to-service credential contract.
2. Cite the exact source files/config/docs or authoritative integration evidence supporting each contract. If the backend or credentials are unavailable, do not guess. Keep connections denied and report the precise blocker.
3. Adapt the verifier to the confirmed contract. Never accept algorithm choice from an untrusted JWT header, trust decoded-but-unverified claims, hard-code secrets, or add a production bypass. Use bounded timeouts and safe key caching/rotation if JWKS is genuinely supported.
4. Keep dashboard-user authentication distinct from internal publisher authentication. Validate signatures and claims, enforce expiry and not-before, and return only the minimum verified claims required downstream.
5. Address browser WebSocket token transport. Use short-lived tokens and log redaction; consider one-time short-lived socket tickets if the canonical flow can support them. Never log tokens.
6. Add tests for valid, expired, malformed, wrong-signature, wrong-issuer, wrong-audience, unsupported-algorithm, missing-claim, key-rotation, revoked-session and verifier-outage behavior as applicable to the real contract.
7. Update docs, environment examples and the checklist. Do not enable tenant joins; Phase 03 owns membership authorization.

## Current-repository warning
A previous change added an HS256-only Joken adapter. It is **not verified compatible** with PesaGuard's canonical issuer. Audit it first and replace/adapt it if the actual issuer differs. Do not set HS256 production secrets by assumption.

## Scope lock
Do not invent issuer/JWKS URLs, claims, secret formats, service tokens or revocation behavior. Do not implement tenant-channel authorization or Kafka consumer behavior in this phase.

## Acceptance checklist
- [ ] Canonical auth contract is evidenced and documented.
- [ ] Verifier matches the real contract and fails closed on missing config/outages.
- [ ] User socket auth and internal publisher auth are separate and explicit.
- [ ] Negative and positive tests cover the applicable security cases.
- [ ] No secret, token or sensitive claim is logged or committed.
- [ ] Frontend/proxy token exposure risks are addressed or explicitly blocked.
- [ ] Real test/CI results are recorded.
- [ ] Tenant channel joins remain denied until Phase 03.

## Required closeout
Update `docs/phase-2-checklist.md`. If the canonical contract cannot be confirmed, label Phase 02 **BLOCKED**, preserve deny-by-default behavior and list exactly what evidence is needed. Do not start Phase 03 automatically.

## Follow-up prompt
“Perform a security-focused review of Phase 02. Compare the verifier with the actual PesaGuard issuer, attempt negative-token tests, inspect secret and log handling, verify the CI run, and fix only authentication defects. Do not infer issuer compatibility from locally generated test tokens.”
