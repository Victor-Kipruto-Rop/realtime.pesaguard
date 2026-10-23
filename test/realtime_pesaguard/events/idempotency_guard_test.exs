defmodule RealtimePesaguard.Events.IdempotencyGuardTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguard.Events.IdempotencyGuard

  defp event_id, do: "evt-idempotency-" <> Integer.to_string(System.unique_integer([:positive]))

  test "claims an event once and rejects a duplicate for the same tenant" do
    id = event_id()

    assert :ok = IdempotencyGuard.claim(id, "tenant-a")
    assert {:error, :duplicate} = IdempotencyGuard.claim(id, "tenant-a")
  end

  test "rejects reuse of an event ID across tenants" do
    id = event_id()

    assert :ok = IdempotencyGuard.claim(id, "tenant-a")
    assert {:error, :event_id_conflict} = IdempotencyGuard.claim(id, "tenant-b")
  end

  test "release permits retry after a failed broadcast" do
    id = event_id()

    assert :ok = IdempotencyGuard.claim(id, "tenant-a")
    assert :ok = IdempotencyGuard.release(id, "tenant-a")
    assert :ok = IdempotencyGuard.claim(id, "tenant-a")
  end

  test "completed delivery remains deduplicated" do
    id = event_id()

    assert :ok = IdempotencyGuard.claim(id, "tenant-a")
    assert :ok = IdempotencyGuard.complete(id, "tenant-a")
    assert {:error, :duplicate} = IdempotencyGuard.claim(id, "tenant-a")
  end
end
