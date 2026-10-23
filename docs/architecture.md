# Architecture

The gateway runs beside the existing PesaGuard Python API.

- Python remains authoritative for tenant identity, transaction state, reconciliation, risk decisions, and audit records.
- Phoenix validates trusted event envelopes and distributes tenant-scoped live notifications.
- Phoenix PubSub fans out events to connected channels.
- Kafka/Redpanda is the intended durable event transport, but its consumer is not enabled until topic names, serialization, schema evolution, acknowledgement, retries, and dead-letter rules are confirmed.

The current internal HTTP event endpoint is an integration scaffold protected by a dedicated bearer token. Use private networking and rotate this token. It is not a substitute for a proper service identity.