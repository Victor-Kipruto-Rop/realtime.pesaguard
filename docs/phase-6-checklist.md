# Phase 6 — Real-time routing and delivery

**Status: PARTIAL IMPLEMENTATION — no verified producer-to-channel end-to-end path.**

## Implemented
- [x] Strict tenant transaction topic helper derives `tenant:<tenant_id>:transactions` server-side.
- [x] Broadcaster revalidates the versioned, allow-listed client event envelope before PubSub broadcast.
- [x] Browser-facing payload is reconstructed from an explicit field allow-list.
- [x] Unit tests cover topic construction, invalid tenant scope, and attempts to bypass event validation.

## Exit gates
- [ ] Connect the real verified Phase 5 consumer to the router.
- [ ] Add end-to-end authorized test delivery from producer/test broker through the consumer into a subscribed Phoenix channel.
- [ ] Prove no cross-tenant delivery during normal, duplicate, retry, reconnect, and malformed-event paths.
- [ ] Define bounded backpressure/slow-client behavior and measured resource limits.
- [ ] Document client heartbeat, reconnect and resubscribe behavior.
- [ ] Run formatting, compilation and tests in a working Elixir/OTP environment.

The internal HTTP publisher endpoint is currently disabled by default. PubSub unit tests are not evidence of end-to-end broker delivery.
