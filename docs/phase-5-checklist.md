# Phase 5 — Event transport and consumer reliability

**Status: BLOCKED — no gateway Kafka/Redpanda consumer is implemented or verified.**

## Verified facts
- The Python backend defines a versioned `EventEnvelope` in `pesaguard_backend_pipeline/event_bus.py`.
- The backend declares event-type/topic mappings and producer helpers in its repository.
- This gateway currently has no verified broker consumer dependency, configured broker/topic credentials, acknowledgement path, or test-broker evidence.

## Exit gates
- [ ] Confirm the deployed broker type, bootstrap endpoints, TLS/SASL settings, consumer group, topic names, and permissions with the backend owner/deployment configuration.
- [ ] Select and pin a maintained Elixir broker client compatible with the project's pinned OTP/Elixir version.
- [ ] Implement a supervised consumer with explicit manual acknowledgement semantics.
- [ ] Validate each message with the approved Phase 4 contract before any broadcast.
- [ ] Implement durable idempotency, bounded retry/backoff, poison-message handling, and a documented DLQ/replay process.
- [ ] Test duplicate, malformed, out-of-order, broker outage, restart, and graceful-shutdown behavior against a real test broker.
- [ ] Record actual broker integration test and CI evidence.

**Safety gate:** Do not guess topic names or broker credentials from the Python repository's defaults. Do not enable production event ingestion or claim durable delivery before the consumer and acknowledgement semantics are verified.
