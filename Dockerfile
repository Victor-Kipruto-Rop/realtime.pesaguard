FROM hexpm/elixir:1.16.3-erlang-26.2.5-debian-bookworm-20240130-slim AS build
ENV MIX_ENV=prod
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile
COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends openssl libstdc++6 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV HOME=/app
COPY --from=build /app/_build/prod/rel/realtime_pesaguard ./
EXPOSE 4000
CMD ["bin/realtime_pesaguard", "start"]