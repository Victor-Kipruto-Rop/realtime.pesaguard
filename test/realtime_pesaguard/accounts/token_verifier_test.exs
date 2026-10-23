defmodule RealtimePesaguard.Accounts.TokenVerifierTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguard.Accounts.TokenVerifier

  defmodule BackendAuthStub do
    def validate("valid-token") do
      {:ok,
       %{
         "user_id" => "user-123",
         "tenant_id" => "tenant-456",
         "roles" => ["operator"],
         "permissions" => ["read:dashboard"]
       }}
    end

    def validate("unavailable-token"), do: {:error, :identity_validation_unavailable}
    def validate(_), do: {:error, :invalid_token}
  end

  setup do
    previous = Application.get_env(:realtime_pesaguard, :backend_auth_client)
    Application.put_env(:realtime_pesaguard, :backend_auth_client, BackendAuthStub)

    on_exit(fn ->
      case previous do
        nil -> Application.delete_env(:realtime_pesaguard, :backend_auth_client)
        value -> Application.put_env(:realtime_pesaguard, :backend_auth_client, value)
      end
    end)

    :ok
  end

  test "accepts only identity returned by canonical backend validation" do
    assert {:ok, claims} = TokenVerifier.verify("valid-token")
    assert claims["sub"] == "user-123"
    assert claims["tenant_id"] == "tenant-456"
    assert claims["roles"] == ["operator"]
    assert claims["permissions"] == ["read:dashboard"]
  end

  test "rejects a token the canonical backend rejects" do
    assert {:error, :invalid_token} = TokenVerifier.verify("forged-token")
  end

  test "fails closed when canonical validation is unavailable" do
    assert {:error, :identity_validation_unavailable} =
             TokenVerifier.verify("unavailable-token")
  end

  test "rejects oversized and non-binary tokens before contacting backend" do
    assert {:error, :invalid_token} = TokenVerifier.verify(String.duplicate("x", 16_385))
    assert {:error, :invalid_token} = TokenVerifier.verify(nil)
  end
end
