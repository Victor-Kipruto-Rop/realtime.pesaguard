# Phase 03 Prompt — Tenant Authorization and Channel Security

## Mission
Guarantee that an authenticated user can subscribe only to the tenant resources they are currently authorized to access.

## Mandatory context
Read the universal prompt rules, Phase 02 outputs/checklist, architecture and security docs, and skills for security, API design, database architecture and testing. Inspect verified identity claims and the canonical membership/role source.

## Execute
1. Determine from the real identity contract whether tenant membership/roles are signed and current, or require authoritative server-side membership lookup. Never assume a `tenant_id` claim alone is sufficient.
2. Implement per-channel authorization using verified claims and/or an authoritative membership check. Derive topic scope server-side; reject mismatches between requested and authorized tenant.
3. Enforce exact resource/action permission checks for supported channel topics. Avoid wildcard grants and client-controlled role/tenant values.
4. Define safe behavior for membership-service timeout, revoked membership, token expiry, logout and role changes. Fail closed.
5. Enforce configured origin allow-list, connection/join limits and safe disconnect/re-authentication behavior where supported.
6. Emit privacy-safe audit records for denials and suspicious access. Never log credentials, full JWTs or unnecessary personal/financial data.
7. Add cross-tenant and privilege-escalation tests, including forged tenant IDs, missing claims, no membership, membership lookup outage, expired credentials and unauthorized topic patterns.

## Scope lock
Do not build the event consumer, expand event payloads or change canonical identity semantics. Keep channel joins denied if the membership contract is not known.

## Acceptance checklist
- [ ] Membership trust model is documented with evidence.
- [ ] Tenant scope is derived from verified identity/authoritative membership, not trusted from client input.
- [ ] Cross-tenant, forged-ID, unauthenticated and privilege-escalation tests pass.
- [ ] Authorization fails closed during dependency outage.
- [ ] Origin/connection controls are configured and tested where applicable.
- [ ] Audit logs are useful but contain no secrets or sensitive payloads.
- [ ] Security review finds no known bypass in implemented paths.

## Required closeout
Update Phase 03 status and record tested authorization cases. Do not proceed to Phase 04 without the exit gate.

## Follow-up prompt
“Attempt to break tenant isolation in Phase 03. Review every socket/channel join and every path that chooses a tenant topic; add regression tests for each bypass found, run the suite, and report evidence. Do not add new features.”
