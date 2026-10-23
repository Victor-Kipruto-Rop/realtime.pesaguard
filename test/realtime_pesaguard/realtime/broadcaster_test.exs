defmodule RealtimePesaguard.Realtime.BroadcasterTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguard.Realtime.Broadcaster

  test "broadcast topic exactly matches the authorized transaction channel" do
    assert Broadcaster.tenant_topic("tenant-a") == "tenant:tenant-a:transactions"
  end

  test "invalid tenant identifiers cannot produce a broadcast topic" do
    assert Broadcaster.tenant_topic("../tenant-b") == nil
  end

  test "rejects a mismatched tenant scope before broadcasting" do
    assert {:error, :invalid_tenant_scope} =
             Broadcaster.broadcast("tenant-a", %{"tenant_id" => "tenant-b"})
  end

  test "rejects invalid tenant identifiers" do
    assert {:error, :invalid_tenant_scope} =
             Broadcaster.broadcast("../tenant-b", %{"tenant_id" => "../tenant-b"})
  end
end
