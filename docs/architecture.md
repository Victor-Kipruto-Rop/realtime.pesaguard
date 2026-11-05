# Architecture

The gateway runs beside the existing PesaGuard Python API.

- Python remains authoritative for tenant identity, transaction state, reconciliation, risk decisions, and audit records.
- The API publishes versioned events to its Kafka-compatible topics through the existing producer and topic registry.
- Phoenix consumes only the approved browser-delivery topics using a dedicated Kafka consumer group.
- The consumer validates event version, schema, event type, topic-to-type mapping, and the producer's tenant/event-type headers before calling the tenant-scoped broadcaster.
- Phoenix PubSub fans out only minimized allow-listed events to authenticated tenant channels.
- Kafka offsets are acknowledged only after local PubSub delivery succeeds. Transient delivery failures restart the subscriber without committing the failed message; the broker can redeliver it.
- Unknown event types on subscribed topics are acknowledged and ignored. They are not exposed to browsers.

## Approved topic bindings

These names are sourced from pesaguard_backend_pipeline/topics.py in the canonical API repository:

| Topic | Browser event |
| --- | --- |
| pesaguard.transactions.failed | transaction.failed |
| pesaguard.transactions.rejected | transaction.rejected |
| pesaguard.fraud.analysis | fraud.analysis.started |

The fraud analysis topic also carries other event types. They remain intentionally blocked by the gateway allow-list until their payload contracts receive an explicit privacy review.

## Local broker configuration

Set KAFKA_BROKERS=redpanda:9092, PESAGUARD_EVENT_CONSUMER_ENABLED=true, and the three-topic allow-list in the local environment. The consumer group defaults to pesaguard-realtime-gateway-v1. The consumer starts at the latest offset for a new group, so it does not replay historical transactions to a newly connected local dashboard.

The gateway reports readiness only after the consumer group has connected. Liveness remains independent of broker availability.

## Security and delivery boundary

The event body is not independently trusted as authorization evidence. The gateway requires the Kafka producer's tenant_id and event_type headers to match the corresponding envelope fields, then validates the tenant identifier and event-specific payload schema before broadcasting. The broker network and credentials must remain private to trusted backend services.

The internal HTTP event-ingest endpoint remains disabled by default and is not used by the Kafka consumer. Do not enable it until a separate authenticated service-to-service contract is implemented and reviewed.
