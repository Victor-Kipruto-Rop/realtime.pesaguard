defmodule RealtimePesaguardWeb.TenantChannelTest do
  use ExUnit.Case, async: true

  alias RealtimePesaguardWeb.TenantChannel

  defp socket_with_claims(claims) do
    %Phoenix.Socket{assigns: %{verified_claims: claims, client_ip: "192.0.2.10"}}
  end

  defp authorized_claims(overrides \\ %{}) do
    Map.merge(
      %{"user_id" => "user-1", "tenant_id" => "tenant-a", "permissions" => ["read:transactions"]},
      overrides
    )
  end

  test "allows a transaction subscription for the verified tenant with permission" do
    assert {:ok, _socket} =
             TenantChannel.join(
               "tenant:tenant-a:transactions",
               %{},
               socket_with_claims(authorized_claims())
             )
  end

  test "does not let join params override the verified tenant" do
    assert {:ok, _socket} =
             TenantChannel.join(
               "tenant:tenant-a:transactions",
               %{"tenant_id" => "tenant-b"},
               socket_with_claims(authorized_claims())
             )
  end

  test "denies a cross-tenant subscription" do
    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join(
               "tenant:tenant-b:transactions",
               %{},
               socket_with_claims(authorized_claims())
             )
  end

  test "denies missing verified identity" do
    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join("tenant:tenant-a:transactions", %{}, %Phoenix.Socket{})
  end

  test "denies missing tenant identity" do
    claims = Map.delete(authorized_claims(), "tenant_id")

    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join(
               "tenant:tenant-a:transactions",
               %{},
               socket_with_claims(claims)
             )
  end

  test "denies missing transaction permission" do
    claims = authorized_claims(%{"permissions" => ["read:reports"]})

    assert {:error, %{reason: "unauthorized"}} =
             TenantChannel.join(
               "tenant:tenant-a:transactions",
               %{},
               socket_with_claims(claims)
             )
  end

  test "denies malformed permissions rather than coercing them" do
    for permissions <- [nil, "read:transactions", ["read:transactions", 42]] do
      claims = authorized_claims(%{"permissions" => permissions})

      assert {:error, %{reason: "unauthorized"}} =
               TenantChannel.join(
                 "tenant:tenant-a:transactions",
                 %{},
                 socket_with_claims(claims)
               )
    end
  end

  test "denies generic, unknown, and extra-segment topics" do
    for topic <- ["tenant:tenant-a", "tenant:tenant-a:reports", "tenant:tenant-a:transactions:all"] do
      assert {:error, %{reason: "unauthorized"}} =
               TenantChannel.join(topic, %{}, socket_with_claims(authorized_claims()))
    end
  end

  test "denies malformed tenant identifiers" do
    for topic <- ["tenant::transactions", "tenant:tenant-a/../tenant-b:transactions"] do
      assert {:error, %{reason: "unauthorized"}} =
               TenantChannel.join(topic, %{}, socket_with_claims(authorized_claims()))
    end
  end
end
