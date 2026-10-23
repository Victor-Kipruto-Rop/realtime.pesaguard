import Config

if config_env() == :prod do
  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise "SECRET_KEY_BASE is required in production"
  port = String.to_integer(System.get_env("PORT", "4000"))
  host = System.get_env("PHX_HOST") || raise "PHX_HOST is required in production"

  config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
    server: true,
    http: [ip: {0, 0, 0, 0}, port: port],
    url: [host: host, port: 443, scheme: "https"],
    secret_key_base: secret_key_base,
    check_origin: System.get_env("PESAGUARD_ALLOWED_ORIGINS", "")
      |> String.split(",", trim: true)
end
