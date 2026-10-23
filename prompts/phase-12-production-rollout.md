# Phase 12 Prompt — Production Rollout and Ongoing Operations

## Mission
Release the verified gateway gradually, measure actual behavior, preserve rollback capability and establish ongoing service ownership.

## Mandatory context
Read universal prompt rules, all phase checklists, security findings, staging evidence, operational runbooks and production-readiness/incident-response/observability skills.

## Execute
1. Verify every Phase 00–11 exit gate using committed checklists and actual command, CI, staging and integration evidence. A checkbox without evidence is not a pass.
2. Confirm there are no unresolved critical/high security or correctness issues unless explicitly accepted by an authorized owner with documented mitigation.
3. Define rollout scope, tenant allow-list/cohort, success metrics, observation window and rollback thresholds from measured staging baseline and explicit business requirements. Do not invent numeric targets.
4. Confirm the Python backend remains the source of truth and only approved events are delivered. Verify no duplicate M-Pesa callback, reconciliation or financial decision processing is introduced.
5. Enable traffic gradually only with explicit approval and the required prior gates. Observe auth failures, cross-tenant denials, event lag, rejection rates, latency, errors, active connections and resource saturation.
6. Define rollback triggers and execute a rollback drill or prove the steps in a safe environment. Preserve audit evidence without retaining sensitive payloads.
7. Assign service ownership, alert response, incident escalation, dependency updates, capacity review and regular recovery/security drills.
8. Produce a release report that separates measured results, known limitations, accepted risks and follow-up work.

## Scope lock
Do not promote automatically, widen tenant scope without approval, or call production healthy based only on liveness or a successful deployment.

## Acceptance checklist
- [ ] Every prior phase exit gate has evidence.
- [ ] Security findings and risk acceptances are documented.
- [ ] Rollout cohort, success criteria and rollback thresholds are approved.
- [ ] End-to-end real event flow and tenant isolation are verified.
- [ ] No duplicated financial processing or fabricated events exist.
- [ ] Monitoring and on-call ownership are active.
- [ ] Rollback is demonstrated or safely drilled.
- [ ] Post-release report reflects actual measurements.

## Required closeout
Record release/rollback identifiers, observed metrics, incidents and owners. If any gate is not met, stop at staging or limited canary and mark production rollout blocked.

## Follow-up prompt
“Perform a post-rollout verification using actual deployment status, logs, telemetry and end-to-end event evidence. Compare measurements with approved thresholds, inspect tenant isolation and rollback readiness, and report go/no-go with evidence. Do not expand rollout scope without explicit approval.”
