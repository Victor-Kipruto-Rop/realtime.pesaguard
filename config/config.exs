import Config

allowed_origins =
  System.get_env("PESAGUARD_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:5173")
  |> String.split(",", trim: true)
  |> Enum.map(&String.trim/1)
  |> Enum.reject(&(&1 == ""))

config :realtime_pesaguard,
  ecto_repos: [],
  event_ingest_token: System.get_env("PESAGUARD_EVENT_INGEST_TOKEN"),
  jwt_hs256_secret: System.get_env("PESAGUARD_JWT_HS256_SECRET"),
  jwt_issuer: System.get_env("PESAGUARD_JWT_ISSUER"),
  jwt_audience: System.get_env("PESAGUARD_JWT_AUDIENCE"),
  allowed_origins: allowed_origins

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [json: RealtimePesaguardWeb.ErrorJSON], layout: false],
  pubsub_server: RealtimePesaguard.PubSub,
  live_view: [signing_salt: "replace-this-in-runtime"]

import_config "#{config_env()}.exs"
