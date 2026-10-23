# System Design Skill

Establish functional and non-functional requirements, traffic assumptions and constraints. Map actors, trust boundaries, data ownership and user journeys. Define service boundaries, sources of truth, API/event contracts, consistency guarantees and failure behavior. Evaluate latency, throughput, availability, recovery, security, cost and operational complexity. Identify single points of failure, backpressure, duplicate delivery and degraded modes. Record important trade-offs and measurable acceptance criteria.

## PesaGuard target
Python owns reconciliation, payment ingestion, financial decisions and canonical business state. Phoenix provides live delivery. PostgreSQL remains authoritative for persisted records. Kafka/Redpanda may transport events after real topics and schemas are confirmed. Do not create a second source of truth without an explicit design decision.
