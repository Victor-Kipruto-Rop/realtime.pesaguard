import Config

config :realtime_pesaguard,
  ecto_repos: [],
  event_ingest_token: System.get_env("PESAGUARD_EVENT_INGEST_TOKEN"),
  allowed_origins:
    System.get_env("PESAGUARD_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:5173")
    |> String.split(",", trim: true)

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [json: RealtimePesaguardWeb.ErrorJSON], layout: false],
  pubsub_server: RealtimePesaguard.PubSub,
  live_view: [signing_salt: "replace-this-in-runtime"]

import_config "#{config_env()}.exs"
