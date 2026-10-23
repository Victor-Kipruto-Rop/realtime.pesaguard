# Event-Driven Architecture Skill

Each event should define stable event ID, event type, schema version, occurrence timestamp, trusted tenant scope, correlation ID and payload schema. Document producer, consumer, ordering expectations, delivery semantics and compatibility rules. Assume at-least-once delivery unless stronger guarantees are proven. Make consumers idempotent. Acknowledge only after durable processing according to the chosen client contract. Define bounded retries, backoff, dead-letter handling, replay and poison-message policy. Monitor consumer lag, retries and rejection counts. Never broadcast arbitrary database rows or sensitive payloads.

Do not configure real broker topics or claim a consumer works until broker settings and event contracts are verified.
