# Event contract — gateway client delivery v1

## Authority and scope

The Python backend repository `Victor-Kipruto-Rop/api.pesaguard` is authoritative for event production. Its `pesaguard_backend_pipeline/event_bus.py` defines `EventEnvelope`, event version `1`, and schema version `1.0`. Its `fraud_events.py` provides an explicit producer function `publish_fraud_analysis_started` whose payload contains `transaction_id` and `model_version`.

The gateway's browser-delivery contract is intentionally narrower than the internal backend envelope. The gateway must not forward raw producer payloads or arbitrary metadata. **Only `fraud.analysis.started`, `transaction.failed`, and `transaction.rejected` are enabled in this initial registry.** This is not a claim that other producer event types are unsupported by the backend; they are simply not yet approved for browser delivery.

## Required client event envelope

- `event_id`: stable, non-empty string, max 160 bytes.
- `event_type`: allow-listed event type.
- `event_version`: integer `1`.
- `schema_version`: string `1.0`.
- `occurred_at`: RFC 3339 timestamp normalized to UTC. The backend's legacy `timestamp` alias is accepted as input and normalized.
- `tenant_id`: trusted tenant scope, max 128 bytes and restricted to the gateway's accepted identifier syntax.
- `aggregate_id`: non-empty internal aggregate identifier, max 160 bytes.
- `correlation_id`: non-empty correlation identifier, max 160 bytes.
- `payload`: object with event-specific strict field allow-list.

Maximum encoded input event size is 65,536 bytes. Unknown top-level fields, unsupported event/schema versions, unregistered event types, invalid timestamps, invalid tenant identifiers, non-object payloads and extra payload fields are rejected. The output is reconstructed from an explicit client-facing field allow-list; producer internals, retry metadata and free-form metadata are not forwarded.

## Initial allow-list

### `transaction.failed` and `transaction.rejected`

Evidence: `pesaguard_backend_pipeline/lifecycle_events.py::pending_lifecycle_event`. The backend constructs payloads with exactly `transaction_id` and a terminal `state`. The gateway requires `state="FAILED"` for `transaction.failed` and `state="REJECTED"` for `transaction.rejected`.

Allowed payload fields (both required):
- `transaction_id`: non-empty string, max 160 bytes.
- `state`: exact event-specific terminal state.

### `fraud.analysis.started`

Evidence: `pesaguard_backend_pipeline/fraud_events.py::publish_fraud_analysis_started`.

Allowed payload fields (both required):
- `transaction_id`: non-empty string, max 160 bytes.
- `model_version`: non-empty string, max 80 bytes.

The gateway rejects `features`, `rules_triggered`, phone/account identifiers, raw transaction data, free-form notes, arbitrary metadata, and every field not explicitly listed above. Other transaction, fraud, and reconciliation event types stay blocked until their producer payloads and privacy requirements are reviewed field by field.

## Tenant trust and ingestion gate

The event's `tenant_id` is not authenticated by this schema alone. It must be derived from the canonical backend's authenticated tenant context, and the internal publisher identity must be verified independently of the event body. Until that producer identity and tenant derivation are enforced and integration-tested, keep `PESAGUARD_EVENT_INGEST_ENABLED=false`. A valid schema does not authorize a caller to publish for a tenant.

## Compatibility policy

- Version 1 accepts only `event_version=1` and `schema_version="1.0"`.
- Add new event types only with an evidence-linked producer, strict payload schema, privacy review, fixtures and compatibility tests.
- Additive payload fields are not implicitly accepted. They require an explicit schema change and review.
- Breaking changes require a new supported schema version and a compatibility window; unknown major versions fail closed.
- Events are notifications only. The canonical Python API remains authoritative for reconciliation, risk decisions and financial state.
