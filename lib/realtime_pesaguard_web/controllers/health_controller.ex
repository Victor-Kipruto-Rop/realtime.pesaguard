defmodule RealtimePesaguardWeb.HealthController do
  use Phoenix.Controller, formats: [:json], layouts: []

  def live(conn, _params) do
    json(conn, %{status: "ok", service: "realtime-pesaguard"})
  end

  def ready(conn, _params) do
    # Until the real identity and event-bus adapters are configured, report not-ready.
    json(conn |> put_status(:service_unavailable), %{
      status: "not_ready",
      reasons: ["identity_verifier_not_configured", "event_bus_consumer_not_configured"]
    })
  end
end
