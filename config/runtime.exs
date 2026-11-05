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

  environment = System.get_env("PESAGUARD_ENVIRONMENT", "production")

  Enum.each(allowed_origins, fn origin ->
    uri = URI.parse(origin)

    exact_origin? =
      is_binary(uri.host) and uri.host != "" and
        uri.path in [nil, ""] and is_nil(uri.query) and is_nil(uri.fragment) and
        is_nil(uri.userinfo) and not String.contains?(origin, "*")

    secure_https_origin? = uri.scheme == "https" and exact_origin?

    local_development_origin? =
      environment in ["development", "test"] and
        uri.scheme == "http" and
        uri.host in ["localhost", "127.0.0.1", "::1"] and
        exact_origin?

    unless secure_https_origin? or local_development_origin? do
      raise "PESAGUARD_ALLOWED_ORIGINS must contain exact HTTPS origins, or exact loopback HTTP origins in development/test only; invalid entry: #{origin}"
    end
  end)

  config :realtime_pesaguard,
    event_ingest_token: System.get_env("PESAGUARD_EVENT_INGEST_TOKEN"),
    event_ingest_enabled: System.get_env("PESAGUARD_EVENT_INGEST_ENABLED") == "true",
    auth_validation_url:
      System.get_env("PESAGUARD_AUTH_VALIDATION_URL") ||
        raise("PESAGUARD_AUTH_VALIDATION_URL is required in production"),
    allowed_origins: allowed_origins

  config :realtime_pesaguard, RealtimePesaguardWeb.Endpoint,
    server: true,
    http: [ip: {0, 0, 0, 0}, port: port],
    url: [host: host, port: 443, scheme: "https"],
    secret_key_base: secret_key_base,
    check_origin: allowed_origins
end
