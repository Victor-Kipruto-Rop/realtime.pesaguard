import Config

allowed_origins =
  System.get_env("PESAGUARD_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:5173")
  |> String.split(",", trim: true)
  |> Enum.map(&String.trim/1)
  |> Enum.reject(&(&1 == ""))

kafka_brokers =
  System.get_env("KAFKA_BROKERS", "")
  |> String.split(",", trim: true)
  |> Enum.map(&String.trim/1)
  |> Enum.reject(&(&1 == ""))

kafka_event_topics =
  System.get_env(
    "PESAGUARD_REALTIME_EVENT_TOPICS",
    "pesaguard.transactions.failed,pesaguard.transactions.rejected,pesaguard.fraud.analysis"
  )
  |> String.split(",", trim: true)
  |> Enum.map(&String.trim/1)
  |> Enum.reject(&(&1 == ""))

config :realtime_pesaguard,
  ecto_repos: [],
  event_ingest_token: System.get_env("PESAGUARD_EVENT_INGEST_TOKEN"),
  event_ingest_enabled: System.get_env("PESAGUARD_EVENT_INGEST_ENABLED") == "true",
  event_consumer_enabled: System.get_env("PESAGUARD_EVENT_CONSUMER_ENABLED") == "true",
  kafka_brokers: kafka_brokers,
  kafka_consumer_group:
    System.get_env("PESAGUARD_REALTIME_CONSUMER_GROUP", "pesaguard-realtime-gateway-v1"),
  kafka_event_topics: kafka_event_topics,
  auth_validation_url: System.get_env("PESAGUARD_AUTH_VALIDATION_URL"),
  allowed_origins: allowed_origins

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [json: RealtimePesaguardWeb.ErrorJSON], layout: false],
  pubsub_server: RealtimePesaguard.PubSub,
  live_view: [signing_salt: "replace-this-in-runtime"]

import_config "#{config_env()}.exs"
