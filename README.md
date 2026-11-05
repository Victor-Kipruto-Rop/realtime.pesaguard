# PesaGuard Real-Time Gateway

Elixir/Phoenix service for tenant-scoped live updates. It complements the existing Python API; it does **not** replace reconciliation, fraud decisions, payment ingestion, or the system of record.

## Responsibilities
- Phoenix Channels/WebSockets for tenant-scoped live updates.
- Consume the API's versioned Kafka/Redpanda events through a dedicated consumer group.
- Validate and minimize event envelopes before broadcasting.
- Enforce tenant-scoped authorization before channel joins and broadcasts.
- Provide liveness and dependency-aware readiness endpoints.

## Safety boundary

The canonical Python API remains authoritative. The gateway forwards only the three event types explicitly allow-listed in the event contract. It does not initiate, confirm, reverse, refund, settle, or move funds. No mock tenant, transaction, or risk data is generated.

The Kafka consumer validates the producer's tenant and event-type headers against the event body. It uses a node-local ten-minute idempotency guard and acknowledges successful deliveries only after Phoenix PubSub accepts the event. Unsupported events are ignored, not exposed to browsers. Deduplication is not durable or distributed. Keep broker access private to trusted backend services.

## Requirements
- Elixir 1.16+ / OTP 26+
- Docker (optional)
- Kafka-compatible Redpanda broker for live event delivery

## Local configuration

Copy .env.example to .env and configure the local-only SECRET_KEY_BASE. The sample file enables the consumer and points it to the local Docker broker service redpanda:9092. When running Phoenix directly on the host instead of in Docker, change the broker to the host-published listener localhost:19092.

Install dependencies, compile, and start the server using the repository's mix tasks. The HTTP server listens on PORT (default 4000). GET /health/live reports process liveness. GET /health/ready remains 503 until the canonical API identity verifier and configured event consumer are ready.

## Event transport

The consumer subscribes to:
- pesaguard.transactions.failed
- pesaguard.transactions.rejected
- pesaguard.fraud.analysis

It uses consumer group pesaguard-realtime-gateway-v1 by default. The gateway accepts only transaction.failed, transaction.rejected, and fraud.analysis.started from those topics. Other event types are deliberately ignored pending schema and privacy review.

## Production checklist

1. Verify the canonical API token-verification contract and tenant membership response against real issuer behavior.
2. Configure Kafka/Redpanda TLS/SASL and broker ACLs so only trusted API producers can publish to the subscribed topics.
3. Use a stable consumer group and explicitly decide whether deployment requires latest-only or historical replay.
4. Configure secrets through the deployment secret manager, not Git.
5. Enable TLS at the edge, rate limits, origin allow-list, metrics/alerts, and dependency readiness checks.
6. Run cross-tenant authorization, event compatibility, broker outage/replay, and load tests before rollout.
7. Deploy alongside the Python backend and roll back by disabling gateway traffic; never change payment-processing behavior from this service.

See docs/architecture.md, docs/security.md, and docs/event-contract.md.
