# Event contract — gateway client delivery v1

## Authority and scope

The Python backend repository Victor-Kipruto-Rop/api.pesaguard is authoritative for event production. Its pesaguard_backend_pipeline/event_bus.py defines EventEnvelope, event version 1, and schema version 1.0. Its pesaguard_backend_pipeline/topics.py maps event types to Kafka-compatible topics.

The gateway's browser-delivery contract is intentionally narrower than the internal backend envelope. The gateway must not forward raw producer payloads or arbitrary metadata. **Only fraud.analysis.started, transaction.failed, and transaction.rejected are enabled in this initial registry.**

## Required client event envelope

- event_id: stable, non-empty string, max 160 bytes.
- event_type: allow-listed event type.
- event_version: integer 1.
- schema_version: string 1.0.
- occurred_at: RFC 3339 timestamp normalized to UTC. The backend's legacy timestamp alias is accepted as input and normalized.
- tenant_id: tenant scope from the canonical backend event, max 128 bytes and restricted to the gateway's accepted identifier syntax.
- aggregate_id: non-empty internal aggregate identifier, max 160 bytes.
- correlation_id: non-empty correlation identifier, max 160 bytes.
- payload: object with event-specific strict field allow-list.

Maximum encoded input event size is 65,536 bytes. Unknown top-level fields, unsupported event/schema versions, unregistered event types, invalid timestamps, invalid tenant identifiers, non-object payloads and extra payload fields are rejected. The output is reconstructed from an explicit client-facing field allow-list; producer internals, retry metadata and free-form metadata are not forwarded.

## Topic and event allow-list

The topic names below are taken from the canonical API topic registry:

| Kafka topic | Accepted event | Evidence |
| --- | --- | --- |
| pesaguard.transactions.failed | transaction.failed | API lifecycle_events.py and topics.py |
| pesaguard.transactions.rejected | transaction.rejected | API lifecycle_events.py and topics.py |
| pesaguard.fraud.analysis | fraud.analysis.started | API fraud_events.py and topics.py |

The fraud analysis topic carries other event types too. The gateway ignores them until their payload contracts are reviewed and added deliberately. A topic name alone never grants permission to broadcast an event.

### Terminal transaction events

The backend constructs payloads with exactly transaction_id and a terminal state. The gateway requires state="FAILED" for transaction.failed and state="REJECTED" for transaction.rejected.

### Fraud analysis started

The backend's publish_fraud_analysis_started producer emits only transaction_id and model_version.

The gateway rejects features, rules_triggered, phone/account identifiers, raw transaction data, free-form notes, arbitrary metadata, and every field not explicitly listed above.

## Broker metadata and tenant isolation

The gateway requires Kafka message headers tenant_id and event_type to match the values in the JSON event body. It then validates the event tenant identifier and exact event-specific payload schema. It never derives tenant authorization from browser-supplied values. The authenticated socket identity and channel join are separately checked against the tenant and read:transactions permission returned by the canonical API.

Only trusted backend producers should have network access and credentials to publish to these topics. Broker ACLs and TLS/SASL must be configured for hosted environments. Local development uses the private Docker network.

## Acknowledgement and retry

- A message is acknowledged after successful validation and PubSub broadcast, or after being intentionally rejected as malformed/unapproved.
- Transient PubSub delivery failures receive bounded in-process retries. If delivery still fails, the subscriber exits without acknowledging, allowing the consumer group to redeliver after restart.
- Kafka consumer group offsets are committed by the broker subscriber.
- The consumer starts at the latest offset for a brand-new group unless a deployment explicitly changes the offset policy. Do not use a new group against production if historical replay is required.
- The internal HTTP ingest route remains disabled by default and is not part of this broker path.

## Compatibility policy

- Version 1 accepts only event_version=1 and schema_version="1.0".
- Add new event types only with an evidence-linked producer, strict payload schema, privacy review, fixtures and compatibility tests.
- Additive payload fields are not implicitly accepted. They require an explicit schema change and review.
- Breaking changes require a new supported schema version and a compatibility window; unknown major versions fail closed.
- Events are notifications only. The canonical Python API remains authoritative for reconciliation, risk decisions and financial state.
