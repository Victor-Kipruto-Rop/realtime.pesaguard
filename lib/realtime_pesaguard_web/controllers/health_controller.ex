defmodule RealtimePesaguardWeb.HealthController do
  use Phoenix.Controller, formats: [:json], layouts: []

  alias RealtimePesaguard.Accounts.BackendAuthClient

  def live(conn, _params) do
    json(conn, %{status: "ok", service: "realtime-pesaguard"})
  end

  def ready(conn, _params) do
    reasons =
      []
      |> maybe_add(not BackendAuthClient.configured?(), "identity_verifier_not_configured")
      |> maybe_add(true, "event_bus_consumer_not_configured")

    if reasons == [] do
      json(conn, %{status: "ready", service: "realtime-pesaguard"})
    else
      conn
      |> put_status(:service_unavailable)
      |> json(%{status: "not_ready", reasons: reasons})
    end
  end

  defp maybe_add(reasons, true, reason), do: reasons ++ [reason]
  defp maybe_add(reasons, false, _reason), do: reasons
end
