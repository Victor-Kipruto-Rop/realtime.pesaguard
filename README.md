# PesaGuard Real-Time Gateway

Elixir/Phoenix service for tenant-scoped live updates. It complements the existing Python API; it does **not** replace reconciliation, fraud decisions, payment ingestion, or the system of record.

## Responsibilities
- Phoenix Channels/WebSockets for live reconciliation progress, risk alerts, and data-source health.
- Validate and normalize event envelopes before broadcasting.
- Enforce tenant-scoped authorization before channel joins and broadcasts.
- Provide health/readiness endpoints and structured operational logging.

## Safety boundary
This initial service is a secure foundation, not a production-ready deployment by itself. Authentication integration with the canonical PesaGuard identity/JWT issuer and the Kafka/Redpanda consumer must be completed and tested against the actual contracts before connecting production traffic. The default channel authorizer denies joins until a verified identity is assigned. No mock tenant, transaction, or risk data is generated.

## Requirements
- Elixir 1.16+ / OTP 26+
- Docker (optional)

## Run locally
```sh
cp .env.example .env
mix local.hex --force
mix local.rebar --force
mix deps.get
mix compile
mix test
mix phx.server
```

The HTTP server listens on `PORT` (default 4000). `GET /health/live` is liveness only. Readiness remains conservative until required production dependencies are configured.

## Event envelope
```json
{
  "event_id": "stable-unique-id",
  "event_type": "reconciliation.updated",
  "occurred_at": "2026-10-23T10:00:00Z",
  "tenant_id": "tenant-id-from-trusted-backend",
  "payload": {}
}
```
Never trust a client-supplied tenant ID for authorization. The tenant must come from verified claims or a trusted backend event. Do not place credentials, full payment identifiers, PINs, or unnecessary personal data in broadcast payloads.

## Production checklist
1. Integrate a real verifier for the canonical PesaGuard access tokens; test issuer, audience, expiry, signature, and tenant claims.
2. Connect the Kafka/Redpanda consumer using the real topic names, schema registry policy, retry strategy, and dead-letter contract.
3. Configure secrets through Render environment variables, not Git.
4. Enable TLS at the edge, rate limits, origin allow-list, metrics/alerts, and dependency readiness checks.
5. Run cross-tenant authorization tests and load tests before rollout.
6. Deploy alongside the Python backend and roll back by disabling gateway traffic; never change payment-processing behavior from this service.

See `docs/architecture.md`, `docs/security.md`, and `docs/event-contract.md`.
