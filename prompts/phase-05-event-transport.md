# Phase 05 Prompt — Event Transport and Consumer Reliability

## Mission
Consume real, contract-validated events from the actual Kafka/Redpanda environment with explicit delivery, acknowledgement, retry and recovery semantics.

## Mandatory context
Read universal prompt rules, Phase 04's approved contract, current messaging adapter and relevant event-driven, DevOps, observability, testing and incident-response skills. Inspect the actual deployed producer/broker configuration.

## Execute
1. Verify broker technology/version, connectivity method, TLS/SASL mechanism, topic names, partitioning/key strategy, consumer group, schema handling, retention, offsets and producer acknowledgement behavior from authoritative configuration.
2. Implement a supervised consumer using maintained compatible dependencies. Keep credentials in environment/secret management. Do not add a broker dependency until its configuration and operational fit are established.
3. Define when offsets/acknowledgements advance relative to validation and successful downstream handoff. Document the resulting at-most/at-least-once implications; never claim exactly-once delivery without proof.
4. Implement stable event-ID deduplication/idempotency, bounded retries with backoff/jitter, poison-message handling, dead-letter or quarantine procedure and replay operations. Avoid infinite retry loops.
5. Handle broker outages, rebalance, malformed records, duplicate/out-of-order events, restart and graceful shutdown.
6. Expose bounded-cardinality consumer lag, retry, rejection, dead-letter and publish-failure metrics; redact payloads in logs.
7. Add tests with a real broker or an explicitly documented compatible test broker. Do not substitute a mock and call it an integration test.

## Scope lock
Do not invent topics, schema registry settings, credentials or delivery guarantees. If the real broker contract cannot be confirmed, implement only a testable adapter boundary and mark transport blocked.

## Acceptance checklist
- [ ] Broker/topic/security settings are evidence-based and documented.
- [ ] Consumer supervision, acknowledgement and shutdown semantics are explicit.
- [ ] Duplicate, malformed, outage, retry, poison-message and restart scenarios are tested.
- [ ] Deduplication/replay behavior is safe and documented.
- [ ] Metrics and logs are bounded and privacy-safe.
- [ ] Real broker integration evidence exists or blocker is explicit.
- [ ] No unsupported delivery guarantee is claimed.

## Required closeout
Update transport runbooks and Phase 05 checklist. Do not proceed to production routing until transport semantics and tests are proven.

## Follow-up prompt
“Exercise Phase 05 failure modes: broker outage, restart, duplicate delivery, malformed record, poison event and slow downstream. Inspect acknowledgement and dedupe behavior, run real integration tests, and correct only reliability defects. Report the exact guarantees proven by tests.”
