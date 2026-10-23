defmodule RealtimePesaguard.Events.EnvelopeTest do
  use ExUnit.Case, async: true
  alias RealtimePesaguard.Events.Envelope

  test "accepts a valid event envelope" do
    event = %{"event_id" => "evt-1", "event_type" => "reconciliation.updated", "occurred_at" => "2026-10-23T10:00:00Z", "tenant_id" => "tenant-1", "payload" => %{"state" => "matched"}}
    assert {:ok, ^event} = Envelope.validate(event)
  end

  test "rejects events missing required fields" do
    assert {:error, {:missing_fields, _}} = Envelope.validate(%{"event_id" => "evt-1"})
  end

  test "rejects a non-map payload" do
    event = %{"event_id" => "evt-1", "event_type" => "reconciliation.updated", "occurred_at" => "2026-10-23T10:00:00Z", "tenant_id" => "tenant-1", "payload" => []}
    assert {:error, :invalid_payload} = Envelope.validate(event)
  end
end