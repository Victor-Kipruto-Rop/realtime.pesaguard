import Config

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  secret_key_base: String.duplicate("dev-only-secret-key-base-", 4)

config :logger, :console, format: "$time $metadata[$level] $message\n", metadata: [:request_id]
