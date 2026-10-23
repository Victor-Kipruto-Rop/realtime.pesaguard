# Phase 04 Prompt — Event Contracts and Validation

## Mission
Define and enforce a versioned, allow-listed event contract shared with the real Python producer. Events are transport notifications, not authoritative financial records.

## Mandatory context
Read the universal prompt rules, `docs/event-contract.md`, architecture/security docs, and event-driven architecture, data engineering, API design, privacy and testing skills. Inspect actual producer code, event schemas, topic configuration and existing envelope validator.

## Execute
1. Inventory event types actually emitted by the Python backend. Use producer code or an authoritative schema as evidence. Do not invent event types, fields or topic names.
2. Agree and document the envelope: stable event ID, event type, schema version, occurrence timestamp, trusted tenant scope, correlation/trace IDs where available, and event-specific payload.
3. Define per-event schemas and strict field allow-lists for only verified dashboard use cases. Include required/optional fields, types, timestamp rules, size limits and compatibility policy.
4. Validate unknown event types/versions, malformed timestamps, duplicate/invalid identifiers, missing tenant scope, oversized payloads and disallowed fields safely.
5. Minimize sensitive data. Never broadcast raw bank/M-Pesa statements, full phone/account identifiers, PINs, access tokens, identity documents or unrestricted database rows.
6. Add producer-consumer contract fixtures and compatibility tests. Keep examples clearly marked as synthetic test fixtures, never as production results.
7. Document versioning, deprecation and rejected-event behavior.

## Scope lock
Do not change Python business logic or claim a producer contract exists without evidence. If no authoritative contract is accessible, propose a clearly marked draft for review and block production compatibility claims.

## Acceptance checklist
- [ ] Event schema and producer source are linked/evidenced.
- [ ] Envelope is versioned and event types are allow-listed.
- [ ] Per-event payloads use strict field allow-lists and size limits.
- [ ] Unknown/invalid/oversized events are rejected safely.
- [ ] Sensitive data is excluded or explicitly minimized.
- [ ] Compatibility tests cover supported and rejected payloads.
- [ ] Contract ownership and compatibility policy are documented.

## Required closeout
Update `docs/event-contract.md` and Phase 04 checklist. Do not proceed to broker consumption until the producer contract is agreed.

## Follow-up prompt
“Review the event contract against the Python producer, field by field. Find schema drift, unsafe fields, missing version handling and weak validation; add contract tests and fix only contract defects. Keep any unverified event type blocked.”
