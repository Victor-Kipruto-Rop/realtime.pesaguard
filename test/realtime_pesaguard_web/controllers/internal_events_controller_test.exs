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

  defp restore_env(key, nil), do: Application.delete_env(:realtime_pesaguard, key)
  defp restore_env(key, value), do: Application.put_env(:realtime_pesaguard, key, value)
end
