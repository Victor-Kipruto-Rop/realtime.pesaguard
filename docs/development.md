# Local Development

## Prerequisites
- Elixir 1.16.x
- Erlang/OTP 26.x
- Git
- Docker Engine/Compose (optional)

Use the versions pinned by CI for reproducible comparisons.

## Setup
```sh
mix local.hex --force
mix local.rebar --force
mix deps.get
mix compile
mix test
```

Run formatting and all local quality gates:

```sh
mix check
```

Start the service:

```sh
mix phx.server
```

The local HTTP endpoint defaults to `http://127.0.0.1:4000`. Liveness is `GET /health/live`; readiness is `GET /health/ready`. Readiness intentionally returns HTTP 503 while the real identity verifier and event transport are not configured.

## Configuration
- `PORT`: local HTTP port; defaults to 4000.
- `PESAGUARD_EVENT_INGEST_TOKEN`: internal event ingestion token. Keep it private and never commit a real value.
- `PESAGUARD_ALLOWED_ORIGINS`: comma-separated, explicit allowed origins.
- `PHX_HOST`: required in production.
- `SECRET_KEY_BASE`: required in production.

Production startup rejects a missing host, secret key base, or empty origin allow-list. A configured token alone does not make the internal event endpoint production-ready; the trusted producer/tenant contract and real authentication integration must also be verified.

## Docker
```sh
docker compose -f docker-compose.dev.yml up --build
```

The Compose file currently runs the release-mode container. It does not provide a real Kafka/Redpanda broker or identity provider. Do not interpret a healthy liveness endpoint as proof those integrations are ready.
