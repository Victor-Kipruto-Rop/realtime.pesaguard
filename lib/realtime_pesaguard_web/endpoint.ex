defmodule RealtimePesaguardWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :realtime_pesaguard

  @session_options [
    store: :cookie,
    key: "_realtime_pesaguard_key",
    signing_salt: "session-signing-salt",
    same_site: "Lax",
    secure: true,
    http_only: true
  ]

  socket "/socket", RealtimePesaguardWeb.UserSocket,
    websocket: [connect_info: [:peer_data, :x_headers]],
    longpoll: false

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  plug Plug.MethodOverride
  plug Plug.Head
  plug RealtimePesaguardWeb.Router
end
