# Phase 07 Prompt — Dashboard Client Integration

## Mission
Integrate the PesaGuard dashboard with the gateway without making browser state the source of truth for financial or risk outcomes.

## Mandatory context
Read universal prompt rules, Phase 02–06 contracts/checklists, dashboard repository/client architecture, and API design, security, testing and documentation skills. Inspect the real frontend auth/session flow before editing.

## Execute
1. Identify the actual dashboard repository, framework, API client, auth/token renewal, logout and environment configuration. Preserve existing conventions and avoid a framework rewrite.
2. Implement a typed, maintained client wrapper for the agreed Phoenix socket protocol and approved event types only.
3. Safely obtain/refresh short-lived credentials according to the canonical auth contract. Avoid long-lived secrets in browser storage; never log tokens. Use a one-time socket ticket if the verified auth design requires it.
4. Implement bounded exponential reconnect backoff with jitter, heartbeat/stale-connection indicators, duplicate-event handling, teardown on logout/tenant switch and resubscription after reconnect.
5. Use events as invalidation/progress notifications. Fetch current state from the authoritative Python API after reconnect or suspected missed events; do not infer successful reconciliation or payment from a socket message alone.
6. Provide accessible loading, disconnected, reconnecting and error states. Avoid mock production data or invented events.
7. Add unit/component and end-to-end tests for connect, authorized events, denied tenant, token expiry, logout, tenant switch, network loss, reconnect and API resynchronization.

## Scope lock
Do not change the Python backend's financial behavior, bypass authentication to make the UI connect, or add unapproved event types.

## Acceptance checklist
- [ ] Client types match the approved server event contract.
- [ ] Auth and tenant switch/logout cleanup are correct.
- [ ] Reconnect uses bounded backoff and jitter.
- [ ] Duplicate and missed events are handled without corrupting authoritative UI state.
- [ ] UI resynchronizes through the canonical API.
- [ ] Disconnected/error states are accessible and truthful.
- [ ] Tests cover lifecycle and security cases; real results are recorded.

## Required closeout
Document frontend environment configuration and update Phase 07 checklist. Do not proceed to API hardening automatically.

## Follow-up prompt
“Review the dashboard gateway client under network failures and account/tenant changes. Test expiry, logout, duplicate events, reconnect storms and API resync; fix only client integration defects and verify the event types against the approved contract.”
