# Phase 10 Prompt — Security, Privacy and Resilience Testing

## Mission
Demonstrate tenant isolation, safe failure behavior, privacy controls and measured capacity under adversarial input and dependency failure.

## Mandatory context
Read universal prompt rules, threat model, auth/tenant/event/transport/API implementations, incident runbooks, and security, privacy, testing and performance skills.

## Execute
1. Build a threat model for identity, tenant boundary, internal publisher, broker, WebSocket clients, secrets, event payloads, logs and deployment access.
2. Run or add regression tests for cross-tenant access, privilege escalation, forged claims, token expiry/revocation, replay, malformed/oversized events, sensitive-field leakage and unsafe errors.
3. Exercise identity-provider outage, broker outage, delayed/duplicate/out-of-order records, poison messages, restart, slow clients and reconnect storms. Use controlled test environments only.
4. Run dependency vulnerability checks and inspect high/critical findings. Do not auto-upgrade major dependencies without compatibility testing.
5. Establish load scenarios and targets from explicit requirements or a measured baseline. Record machine size, concurrency, event rate, duration, error rate, latency percentiles and resource use. Do not invent capacity claims.
6. Review retention/minimization, access to logs, incident response, credential rotation and data deletion requirements applicable to this service.
7. Classify findings by severity, owner, mitigation and status. Critical/high issues block production unless formally accepted by an authorized owner with documented mitigation.

## Scope lock
Do not run destructive tests against production, collect unnecessary real personal/financial data, or call a system secure solely because tests pass.

## Acceptance checklist
- [ ] Threat model and test conditions are documented.
- [ ] Tenant-isolation and auth regression tests pass.
- [ ] Dependency/failure/load tests have real recorded outcomes.
- [ ] Critical/high findings are fixed or formally accepted with owner and mitigation.
- [ ] Privacy, retention and incident procedures are documented.
- [ ] No unmeasured capacity or security guarantees are claimed.

## Required closeout
Publish a test evidence summary and update Phase 10 checklist. Any unresolved critical/high issue blocks Phase 11 production promotion.

## Follow-up prompt
“Act as an independent security reviewer. Challenge tenant boundaries, credentials, event validation, retry/replay behavior, privacy and outage handling; reproduce findings safely, add regression tests, and produce a severity-ranked evidence report. Do not make unrelated changes.”
