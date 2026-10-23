# Data Engineering Skill

- Separate ingestion, validation, normalization, matching, exception handling and reporting.
- Preserve raw source evidence with access controls and documented retention.
- Make processing idempotent using stable source/event identifiers and constraints.
- Track source, ingestion time, event time, processing time, schema version and correlation IDs.
- Handle duplicate, delayed, missing, malformed and out-of-order events explicitly.
- Use decimal-safe money representation, explicit currency, timezone, sign and rounding rules.
- Reconcile counts and totals across pipeline stages.
- Quarantine invalid records with actionable reason codes instead of silently dropping them.
- Version transformations and maintain lineage from source to output.
- Protect sensitive fields and define retention/deletion behavior.

Never invent transaction records. An unmatched transaction is not automatically fraud; use defined rules and reviewable evidence.
