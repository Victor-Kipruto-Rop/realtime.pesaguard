import Config

config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4000"))],
  debug_errors: true,
  code_reloader: false,
  check_origin: ["//localhost", "//127.0.0.1"],
  secret_key_base: String.duplicate("dev-only-secret-key-base-", 4)

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
