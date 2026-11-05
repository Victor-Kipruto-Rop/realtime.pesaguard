defmodule RealtimePesaguardWeb.TenantChannelTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguardWeb.TenantChannel

  test "allows a verified user to join only their own tenant channel" do
    socket = %Phoenix.Socket{assigns: %{verified_claims: %{"tenant_id" => "tenant-a"}}}

    assert {:ok, ^socket} = TenantChannel.join("tenant:tenant-a", %{}, socket)
  end

  test "rejects a cross-tenant channel join" do
    socket = %Phoenix.Socket{assigns: %{verified_claims: %{"tenant_id" => "tenant-a"}}}

    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join("tenant:tenant-b", %{}, socket)
  end

  test "rejects joins without verified identity claims" do
    socket = %Phoenix.Socket{}

    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join("tenant:tenant-a", %{}, socket)
  end
end
