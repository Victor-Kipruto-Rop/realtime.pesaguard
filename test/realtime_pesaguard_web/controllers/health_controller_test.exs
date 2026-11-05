defmodule RealtimePesaguardWeb.HealthControllerTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguardWeb.HealthController

  test "liveness succeeds without requiring downstream dependencies" do
    conn = Plug.Test.conn(:get, "/health/live") |> HealthController.live(%{})

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body)["status"] == "ok"
  end

  test "local API auth configuration clears only the identity readiness blocker" do
    previous_url = Application.get_env(:realtime_pesaguard, :auth_validation_url)
    previous_environment = System.get_env("PESAGUARD_ENVIRONMENT")
    Application.put_env(
      :realtime_pesaguard,
      :auth_validation_url,
      "http://dashboard_api:5001/auth/verify"
    )
    System.put_env("PESAGUARD_ENVIRONMENT", "development")

    on_exit(fn ->
      if is_nil(previous_url) do
        Application.delete_env(:realtime_pesaguard, :auth_validation_url)
      else
        Application.put_env(:realtime_pesaguard, :auth_validation_url, previous_url)
      end

      if is_nil(previous_environment) do
        System.delete_env("PESAGUARD_ENVIRONMENT")
      else
        System.put_env("PESAGUARD_ENVIRONMENT", previous_environment)
      end
    end)

    conn =
      Plug.Test.conn(:get, "/health/ready")
      |> RealtimePesaguardWeb.Router.call(RealtimePesaguardWeb.Router.init([]))

    body = Jason.decode!(conn.resp_body)
    refute "identity_verifier_not_configured" in body["reasons"]
    assert "event_bus_consumer_not_configured" in body["reasons"]
  end

  test "readiness stays closed while the real event consumer is not configured" do
    previous = Application.get_env(:realtime_pesaguard, :event_consumer_configured)
    Application.put_env(:realtime_pesaguard, :event_consumer_configured, false)

    on_exit(fn ->
      if is_nil(previous) do
        Application.delete_env(:realtime_pesaguard, :event_consumer_configured)
      else
        Application.put_env(:realtime_pesaguard, :event_consumer_configured, previous)
      end
    end)

    conn = Plug.Test.conn(:get, "/health/ready") |> HealthController.ready(%{})

    assert conn.status == 503
    body = Jason.decode!(conn.resp_body)
    assert body["status"] == "not_ready"
    assert "event_bus_consumer_not_configured" in body["reasons"]
  end
end
