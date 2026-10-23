defmodule RealtimePesaguard.Tenants.AccessPolicyTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguard.Tenants.AccessPolicy

  test "permits the same verified tenant" do
    assert :ok = AccessPolicy.authorize_join(%{"tenant_id" => "tenant-a"}, "tenant-a")
  end

  test "rejects cross-tenant join" do
    assert {:error, :tenant_forbidden} =
             AccessPolicy.authorize_join(%{"tenant_id" => "tenant-a"}, "tenant-b")
  end

  test "rejects missing verified claims" do
    assert {:error, :unauthorized} = AccessPolicy.authorize_join(%{}, "tenant-a")
  end
end
