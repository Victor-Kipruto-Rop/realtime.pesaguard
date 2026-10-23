# Event contract

Each event must contain `event_id`, `event_type`, `occurred_at`, `tenant_id`, and object-valued `payload`.

Suggested event types (confirm against backend implementation before use):
- `reconciliation.updated`
- `risk.alert_created`
- `datasource.health_changed`
- `security.activity_recorded`

Rules:
- Event IDs must be stable across retries.
- `occurred_at` should be RFC 3339 UTC; current validation checks presence only, so strict timestamp parsing remains required.
- Tenant ID must originate from trusted backend context.
- Define a payload schema and version per event type; never publish arbitrary database rows.
- Confirm retention, retry, dead-letter, ordering, and offset strategies before Kafka activation.