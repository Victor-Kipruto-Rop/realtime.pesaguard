defmodule RealtimePesaguardWeb.HealthController do
  use Phoenix.Controller, formats: [:json], layouts: []

  @required_processes [
    RealtimePesaguard.Finch,
    RealtimePesaguard.Security.RateLimiter,
    RealtimePesaguard.Events.IdempotencyGuard,
    RealtimePesaguard.Accounts.SocketSessionMonitor,
    RealtimePesaguard.PubSub
  ]

  def live(conn, _params) do
    json(conn, %{status: "ok", service: "realtime-pesaguard"})
  end

  def ready(conn, _params) do
    reasons =
      []
      |> add_missing_processes()
      |> add_missing_auth_configuration()
      |> add_missing_event_consumer()

    if reasons == [] do
      json(conn, %{status: "ready", service: "realtime-pesaguard"})
    else
      conn
      |> put_status(:service_unavailable)
      |> json(%{status: "not_ready", service: "realtime-pesaguard", reasons: reasons})
    end
  end

  defp add_missing_processes(reasons) do
    missing =
      Enum.reject(@required_processes, fn name ->
        case Process.whereis(name) do
          pid when is_pid(pid) -> Process.alive?(pid)
          _ -> false
        end
      end)

    if missing == [] do
      reasons
    else
      ["required_process_unavailable" | reasons]
    end
  end

  defp add_missing_auth_configuration(reasons) do
    url = Application.get_env(:realtime_pesaguard, :auth_validation_url)

    if is_binary(url) and String.starts_with?(url, "https://") do
      reasons
    else
      ["identity_verifier_not_configured" | reasons]
    end
  end

  defp add_missing_event_consumer(reasons) do
    # This remains false until a verified broker consumer is implemented and supervised.
    if Application.get_env(:realtime_pesaguard, :event_consumer_configured, false) do
      reasons
    else
      ["event_bus_consumer_not_configured" | reasons]
    end
  end
end
