# Build stage
FROM hexpm/elixir:1.16.3-erlang-26.2.5-debian-bookworm-20240130-slim AS build

ENV MIX_ENV=prod
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs ./
COPY config config
RUN mix deps.get --only prod && mix deps.compile

COPY lib lib
COPY priv priv
RUN mix compile --warnings-as-errors
RUN mix release

# Runtime stage
FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl libstdc++6 ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV HOME=/app
ENV MIX_ENV=prod

RUN useradd --system --uid 10001 --create-home appuser
COPY --from=build --chown=appuser:appuser /app/_build/prod/rel/realtime_pesaguard ./

USER appuser
EXPOSE 4000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl --fail --silent http://127.0.0.1:4000/health/live || exit 1

CMD ["bin/realtime_pesaguard", "start"]
