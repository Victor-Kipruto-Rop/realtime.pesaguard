# PesaGuard Real-Time Gateway

Elixir/Phoenix service for tenant-scoped live updates. It complements the existing Python API; it does **not** replace reconciliation, fraud decisions, payment ingestion, or the system of record.

## Responsibilities
- Phoenix Channels/WebSockets for live reconciliation progress, risk alerts, and data-source health.
- Validate and normalize event envelopes before broadcasting.
- Enforce tenant-scoped authorization before channel joins and broadcasts.
- Provide health/readiness endpoints and structured operational logging.

## Safety boundary
This initial service is a secure foundation, not a production-ready deployment by itself. Authentication integration with the canonical PesaGuard identity/JWT issuer and the Kafka/Redpanda consumer must be completed and tested against the actual contracts before connecting production traffic. The socket validates access tokens against the canonical PesaGuard API, and the channel authorizer permits a join only when the verified tenant claim exactly matches the requested tenant channel. No mock tenant, transaction, or risk data is generated.

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

The HTTP server listens on `PORT` (default 4000). `GET /health/live` is liveness only. For the coordinated local PesaGuard Compose network, set `PESAGUARD_ENVIRONMENT=development` and `PESAGUARD_AUTH_VALIDATION_URL=http://dashboard_api:5001/auth/verify`; plaintext HTTP is accepted only for the explicitly allow-listed local API hosts in development/test. Hosted environments require HTTPS. `GET /health/ready` remains unavailable until the event-bus consumer is implemented and configured.

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


## Repository scaffold

```text
config/                         runtime configuration by environment
lib/realtime_pesaguard/
  accounts/                     canonical token-verifier adapter boundary
  tenants/                      tenant authorization policy
  events/                       event envelope validation
  messaging/                    Kafka/Redpanda consumer boundary
  notifications/                supported event routing
  realtime/                     tenant-scoped Phoenix PubSub broadcasting
  integrations/                 external adapter boundary
  observability/                 metrics definitions
  rate_limiting/                 rate-limit policy
lib/realtime_pesaguard_web/
  controllers/                  health and internal event endpoints
  plugs/                        reusable security plugs
  serializers/                  event payload allow-list boundary
  channels/                     Phoenix tenant channel
  endpoint.ex                   HTTP/WebSocket endpoint
  router.ex                     HTTP routes
  user_socket.ex                default-deny socket authentication
assets/js/realtime/              browser client entry point
test/
  integration/                  dependency-backed integration tests
  security/                     auth and cross-tenant tests
  load/                         load/soak scenarios
  realtime_pesaguard/            unit tests by domain
  realtime_pesaguard_web/        endpoint/controller tests
docs/                            architecture, auth, contracts, security, ops
infra/
  scripts/                       operational scripts
  monitoring/                    dashboards and alert rules
.github/workflows/               CI workflow
Dockerfile                       container build
docker-compose.dev.yml            local container setup
render.yaml                      Render Blueprint starter
```

Directories marked with `.keep` are intentionally scaffold-only. Adapters and tests must be completed against real PesaGuard contracts before production use.


## Development quality gates

Run the shared quality gate before opening a change:

```sh
mix check
```

Or run the steps separately:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
docker build --tag realtime-pesaguard:local .
```

See [local development](docs/development.md) and the [Phase 1 checklist](docs/phase-1-checklist.md) for setup and known verification gaps. A successful liveness response does not mean identity or event transport is ready.

## AI implementation prompts

Use the strict, phase-by-phase execution pack in [`prompts/README.md`](prompts/README.md). It contains a dedicated prompt for every phase (00–12), phase acceptance checklists, and follow-up prompts for verification, debugging, security review, contract discovery, CI review and handoff. Agents must execute one phase at a time and must not claim completion without evidence.

## Authentication status

Socket handshakes delegate access-token verification to the canonical PesaGuard API so key rotation, session revocation and account state are not duplicated in the gateway. Tenant channel joins compare the verified tenant claim with the requested tenant channel and fail closed on mismatch. Local HTTP is accepted only for the explicitly allow-listed Docker DNS/loopback hosts when `PESAGUARD_ENVIRONMENT=development` or `test`; production and staging require HTTPS. The Kafka/Redpanda consumer and event delivery contract remain unimplemented, so the service is not production-ready. See [authentication contract](docs/authentication.md), [security controls](docs/security.md), and the [Phase 2 checklist](docs/phase-2-checklist.md). This gateway is not ready for production while identity interoperability and event transport remain unverified.
