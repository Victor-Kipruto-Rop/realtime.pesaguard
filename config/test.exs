import Config

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false,
  secret_key_base: String.duplicate("test-only-secret-key-base-", 4),
  check_origin: false

config :logger, level: :warning
