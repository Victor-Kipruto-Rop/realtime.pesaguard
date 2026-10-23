# Phase 7 — Dashboard client integration

**Status: NOT IMPLEMENTED / BLOCKED ON VERIFIED SERVER DELIVERY.**

## Exit gates
- [ ] Confirm the actual dashboard application/repository and supported build/runtime before adding client code.
- [ ] Add a maintained JavaScript client wrapper using the agreed Phoenix Channels client dependency/version.
- [ ] Acquire credentials through the existing authenticated dashboard flow; never hard-code service tokens or place them in browser bundles.
- [ ] Implement typed handlers only for event types approved in `docs/event-contract.md`.
- [ ] Add bounded exponential reconnect with jitter, stale-connection state, logout cleanup and token renewal behavior.
- [ ] Deduplicate client event IDs and recover authoritative state from the Python API after reconnect or missed delivery.
- [ ] Add browser integration tests for authorization, rendering, reconnect, logout, expired credentials and API recovery.

Do not invent dashboard repository paths or wire the client to a production gateway before Phases 2–6 have verified exit evidence.
