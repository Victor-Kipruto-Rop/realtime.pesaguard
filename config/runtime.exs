import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE is required in production"

  host =
    System.get_env("PHX_HOST") ||
      raise "PHX_HOST is required in production"

  port =
    System.get_env("PORT", "4000")
    |> String.to_integer()

  allowed_origins =
    System.get_env("PESAGUARD_ALLOWED_ORIGINS", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))

  if allowed_origins == [] do
    raise "PESAGUARD_ALLOWED_ORIGINS must contain at least one trusted origin in production"
  end

  config :realtime_pesaguard,
    event_ingest_token: System.get_env("PESAGUARD_EVENT_INGEST_TOKEN"),
    jwt_hs256_secret: System.get_env("PESAGUARD_JWT_HS256_SECRET"),
    jwt_issuer: System.get_env("PESAGUARD_JWT_ISSUER"),
    jwt_audience: System.get_env("PESAGUARD_JWT_AUDIENCE"),
    allowed_origins: allowed_origins

  config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
    server: true,
    http: [ip: {0, 0, 0, 0}, port: port],
    url: [host: host, port: 443, scheme: "https"],
    secret_key_base: secret_key_base,
    check_origin: allowed_origins
end
