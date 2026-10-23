defmodule RealtimePesaguard.Events.EnvelopeTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguard.Events.Envelope

  defp valid_event(overrides \\ %{}) do
    Map.merge(
      %{
        "event_id" => "evt-1",
        "event_type" => "fraud.analysis.started",
        "event_version" => 1,
        "schema_version" => "1.0",
        "occurred_at" => "2026-10-23T10:00:00Z",
        "tenant_id" => "tenant-1",
        "aggregate_id" => "tx-1",
        "correlation_id" => "corr-1",
        "payload" => %{"transaction_id" => "tx-1", "model_version" => "risk-v1"}
      },
      overrides
    )
  end

  test "accepts a known versioned event and returns only the client contract" do
    event = valid_event() |> Map.put("producer", "pesaguard.fraud_events")

    assert {:ok, result} = Envelope.validate(event)
    assert result["event_type"] == "fraud.analysis.started"
    assert result["payload"] == %{"transaction_id" => "tx-1", "model_version" => "risk-v1"}
    refute Map.has_key?(result, "producer")
  end

  test "accepts the checked-in synthetic fixture matching the Python producer contract" do
    fixture_path = Path.join(__DIR__, "../../fixtures/fraud_analysis_started_v1.json")
    event = fixture_path |> File.read!() |> Jason.decode!()

    assert {:ok, result} = Envelope.validate(event)
    assert result["event_type"] == "fraud.analysis.started"
    assert result["payload"] == %{
             "transaction_id" => "transaction-test-001",
             "model_version" => "risk-model-test-v1"
           }
  end

  test "rejects events missing required fields" do
    assert {:error, {:missing_fields, _}} = Envelope.validate(%{"event_id" => "evt-1"})
  end

  test "rejects an unsupported event type" do
    assert {:error, :unsupported_event_type} =
             Envelope.validate(valid_event(%{"event_type" => "reconciliation.completed"}))
  end

  test "rejects unsupported contract versions" do
    assert {:error, :unsupported_event_version} =
             Envelope.validate(valid_event(%{"event_version" => 2}))

    assert {:error, :unsupported_schema_version} =
             Envelope.validate(valid_event(%{"schema_version" => "2.0"}))
  end

  test "rejects malformed and non-UTC timestamps" do
    assert {:error, :invalid_occurred_at} =
             Envelope.validate(valid_event(%{"occurred_at" => "yesterday"}))

    assert {:error, :timestamp_must_be_utc} =
             Envelope.validate(valid_event(%{"occurred_at" => "2026-10-23T10:00:00+03:00"}))
  end

  test "accepts the producer timestamp alias and normalizes it" do
    event =
      valid_event()
      |> Map.delete("occurred_at")
      |> Map.put("timestamp", "2026-10-23T10:00:00+00:00")

    assert {:ok, result} = Envelope.validate(event)
    assert result["occurred_at"] == "2026-10-23T10:00:00Z"
    refute Map.has_key?(result, "timestamp")
  end

  test "rejects payload fields not explicitly allow-listed" do
    payload = %{"transaction_id" => "tx-1", "model_version" => "risk-v1", "features" => %{"phone" => "sensitive"}}

    assert {:error, :unknown_payload_fields} =
             Envelope.validate(valid_event(%{"payload" => payload}))
  end

  test "rejects unknown top-level fields" do
    assert {:error, :unknown_event_fields} =
             Envelope.validate(valid_event(%{"raw_transaction" => %{"MSISDN" => "254700000000"}}))
  end

  test "rejects a non-object payload" do
    assert {:error, :invalid_payload} = Envelope.validate(valid_event(%{"payload" => []}))
  end

  test "rejects oversized events" do
    oversized = valid_event(%{"payload" => %{"transaction_id" => "tx-1", "model_version" => String.duplicate("x", 70_000)}})
    assert {:error, :event_too_large} = Envelope.validate(oversized)
  end

  test "rejects invalid tenant identifiers" do
    assert {:error, :invalid_tenant_id} =
             Envelope.validate(valid_event(%{"tenant_id" => "../other-tenant"}))
  end
end
