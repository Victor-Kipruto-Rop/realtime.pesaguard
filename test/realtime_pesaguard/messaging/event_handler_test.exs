defmodule RealtimePesaguard.Messaging.EventHandlerTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguard.Messaging.EventHandler

  setup do
    :ok = Phoenix.PubSub.subscribe(RealtimePesaguard.PubSub, "tenant:tenant-a:transactions")
    :ok
  end

  test "broadcasts only the minimized approved event after broker metadata matches" do
    event = %{
      "event_id" => "evt-handler-1",
      "event_type" => "transaction.failed",
      "event_version" => 1,
      "schema_version" => "1.0",
      "occurred_at" => "2026-10-23T10:00:00Z",
      "tenant_id" => "tenant-a",
      "aggregate_id" => "tx-1",
      "correlation_id" => "corr-1",
      "payload" => %{"transaction_id" => "tx-1", "state" => "FAILED"},
      "metadata" => %{"internal" => "must-not-leak"}
    }

    message = kafka_message(Jason.encode!(event), [
      {~c"tenant_id", "tenant-a"},
      {~c"event_type", "transaction.failed"}
    ])

    assert {:ok, :ack, %{}} =
             EventHandler.handle_message(~c"pesaguard.transactions.failed", 0, message, %{})

    assert_receive {:pesaguard_event, delivered}
    assert delivered["tenant_id"] == "tenant-a"
    assert delivered["payload"] == %{"transaction_id" => "tx-1", "state" => "FAILED"}
    refute Map.has_key?(delivered, "metadata")
  end

  test "does not broadcast when broker tenant metadata differs from the event body" do
    event = %{
      "event_id" => "evt-handler-2",
      "event_type" => "transaction.failed",
      "event_version" => 1,
      "schema_version" => "1.0",
      "occurred_at" => "2026-10-23T10:00:00Z",
      "tenant_id" => "tenant-a",
      "aggregate_id" => "tx-2",
      "correlation_id" => "corr-2",
      "payload" => %{"transaction_id" => "tx-2", "state" => "FAILED"}
    }

    message = kafka_message(Jason.encode!(event), [
      {~c"tenant_id", "tenant-b"},
      {~c"event_type", "transaction.failed"}
    ])

    assert {:ok, :ack, %{}} =
             EventHandler.handle_message(~c"pesaguard.transactions.failed", 0, message, %{})

    refute_receive {:pesaguard_event, _}
  end

  test "acknowledges but never forwards an event outside the browser allow-list" do
    event = %{
      "event_id" => "evt-handler-3",
      "event_type" => "fraud.analysis.completed",
      "tenant_id" => "tenant-a"
    }

    message = kafka_message(Jason.encode!(event), [
      {~c"tenant_id", "tenant-a"},
      {~c"event_type", "fraud.analysis.completed"}
    ])

    assert {:ok, :ack, %{}} =
             EventHandler.handle_message(~c"pesaguard.fraud.analysis", 0, message, %{})

    refute_receive {:pesaguard_event, _}
  end

  defp kafka_message(value, headers) do
    {:kafka_message, 7, <<>>, value, :create, 1_798_000_000_000, headers}
  end
end
