defmodule RealtimePesaguardWeb.InternalEventsControllerTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguardWeb.InternalEventsController

  setup do
    previous_enabled = Application.get_env(:realtime_pesaguard, :event_ingest_enabled)
    previous_token = Application.get_env(:realtime_pesaguard, :event_ingest_token)

    on_exit(fn ->
      restore_env(:event_ingest_enabled, previous_enabled)
      restore_env(:event_ingest_token, previous_token)
    end)

    :ok
  end

  test "event ingestion stays disabled even when a bearer token is configured" do
    Application.put_env(:realtime_pesaguard, :event_ingest_enabled, false)
    Application.put_env(:realtime_pesaguard, :event_ingest_token, "configured-test-token")

    conn =
      Plug.Test.conn(:post, "/internal/events", %{"tenant_id" => "tenant-a"})
      |> InternalEventsController.create(%{"tenant_id" => "tenant-a"})

    assert conn.status == 503
    assert Jason.decode!(conn.resp_body) == %{"error" => "event_ingest_disabled"}
  end

  test "accepts and broadcasts only a validated client-safe event when explicitly enabled" do
    Application.put_env(:realtime_pesaguard, :event_ingest_enabled, true)
    Application.put_env(:realtime_pesaguard, :event_ingest_token, "configured-test-token")

    event = %{
      "event_id" => "evt-test",
      "event_type" => "transaction.failed",
      "event_version" => 1,
      "schema_version" => "1.0",
      "occurred_at" => "2026-10-23T10:00:00Z",
      "tenant_id" => "tenant-a",
      "aggregate_id" => "tx-test",
      "correlation_id" => "corr-test",
      "payload" => %{"transaction_id" => "tx-test", "state" => "FAILED"}
    }

    assert :ok =
             Phoenix.PubSub.subscribe(
               RealtimePesaguard.PubSub,
               "tenant:tenant-a:transactions"
             )

    conn =
      Plug.Test.conn(:post, "/internal/events", event)
      |> Plug.Conn.put_req_header("authorization", "Bearer configured-test-token")
      |> InternalEventsController.create(event)

    assert conn.status == 202
    assert Jason.decode!(conn.resp_body) == %{"accepted" => true, "event_id" => "evt-test"}
    assert_receive {:pesaguard_event, delivered}
    assert delivered["tenant_id"] == "tenant-a"
    assert delivered["payload"] == %{"transaction_id" => "tx-test", "state" => "FAILED"}
  end

  test "rejects unregistered event types without exposing validator internals" do
    Application.put_env(:realtime_pesaguard, :event_ingest_enabled, true)
    Application.put_env(:realtime_pesaguard, :event_ingest_token, "configured-test-token")

    event = %{
      "event_id" => "evt-test",
      "event_type" => "unknown.event",
      "event_version" => 1,
      "schema_version" => "1.0",
      "occurred_at" => "2026-10-23T10:00:00Z",
      "tenant_id" => "tenant-a",
      "aggregate_id" => "tx-test",
      "correlation_id" => "corr-test",
      "payload" => %{}
    }

    conn =
      Plug.Test.conn(:post, "/internal/events", event)
      |> Plug.Conn.put_req_header("authorization", "Bearer configured-test-token")
      |> InternalEventsController.create(event)

    assert conn.status == 422
    assert Jason.decode!(conn.resp_body) == %{"error" => "invalid_event"}
  end

  defp restore_env(key, nil), do: Application.delete_env(:realtime_pesaguard, key)
  defp restore_env(key, value), do: Application.put_env(:realtime_pesaguard, key, value)
end
