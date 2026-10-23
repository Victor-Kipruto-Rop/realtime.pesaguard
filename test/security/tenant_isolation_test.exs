defmodule RealtimePesaguard.Security.TenantIsolationTest do
  use ExUnit.Case, async: true
  alias RealtimePesaguard.Tenants.AccessPolicy

  test "verified tenant A cannot join tenant B topic" do
    refute AccessPolicy.authorize_join(%{"tenant_id" => "tenant-a"}, "tenant-b") == :ok
  end
end
