defmodule RealtimePesaguard.Accounts.TokenVerifierTest do
  use ExUnit.Case, async: false

  alias RealtimePesaguard.Accounts.TokenVerifier

  @secret String.duplicate("test-secret-", 4)
  @issuer "https://identity.example.test"
  @audience "pesaguard-realtime"

  defmodule TestToken do
    use Joken.Config

    @impl Joken.Config
    def token_config do
      default_claims(iss: "https://identity.example.test", aud: "pesaguard-realtime", default_exp: 300)
      |> add_claim("sub", nil, &is_binary/1)
      |> add_claim("tenant_id", nil, &is_binary/1)
    end
  end

  setup do
    previous = %{
      jwt_hs256_secret: Application.get_env(:realtime_pesaguard, :jwt_hs256_secret),
      jwt_issuer: Application.get_env(:realtime_pesaguard, :jwt_issuer),
      jwt_audience: Application.get_env(:realtime_pesaguard, :jwt_audience)
    }

    Application.put_env(:realtime_pesaguard, :jwt_hs256_secret, @secret)
    Application.put_env(:realtime_pesaguard, :jwt_issuer, @issuer)
    Application.put_env(:realtime_pesaguard, :jwt_audience, @audience)

    on_exit(fn ->
      Enum.each(previous, fn
        {key, nil} -> Application.delete_env(:realtime_pesaguard, key)
        {key, value} -> Application.put_env(:realtime_pesaguard, key, value)
      end)
    end)

    :ok
  end

  test "accepts a correctly signed token with required identity claims" do
    assert {:ok, token, _claims} =
             Joken.generate_and_sign(TestToken, %{"sub" => "user-123", "tenant_id" => "tenant-456"},
               Joken.Signer.create("HS256", @secret)
             )

    assert {:ok, claims} = TokenVerifier.verify(token)
    assert claims["sub"] == "user-123"
    assert claims["tenant_id"] == "tenant-456"
    assert claims["iss"] == @issuer
    assert claims["aud"] == @audience
  end

  test "rejects malformed tokens" do
    assert {:error, :invalid_token} = TokenVerifier.verify("not-a-jwt")
  end

  test "rejects a token signed with the wrong secret" do
    {:ok, token, _claims} =
      Joken.generate_and_sign(TestToken, %{"sub" => "user-123", "tenant_id" => "tenant-456"},
        Joken.Signer.create("HS256", "a-different-secret-that-is-long-enough")
      )

    assert {:error, :invalid_token} = TokenVerifier.verify(token)
  end

  test "fails closed when verifier configuration is missing" do
    Application.delete_env(:realtime_pesaguard, :jwt_hs256_secret)
    assert {:error, :identity_verifier_not_configured} = TokenVerifier.verify("any-token")
  end

  test "rejects tokens missing tenant identity" do
    {:ok, token, _claims} =
      Joken.generate_and_sign(TestToken, %{"sub" => "user-123"},
        Joken.Signer.create("HS256", @secret)
      )

    assert {:error, _reason} = TokenVerifier.verify(token)
  end

  test "rejects expired tokens" do
    expired = System.system_time(:second) - 60

    {:ok, token, _claims} =
      Joken.generate_and_sign(
        TestToken,
        %{"sub" => "user-123", "tenant_id" => "tenant-456", "exp" => expired},
        Joken.Signer.create("HS256", @secret)
      )

    assert {:error, :invalid_token} = TokenVerifier.verify(token)
  end

  test "rejects tokens that are not yet valid" do
    future = System.system_time(:second) + 300

    {:ok, token, _claims} =
      Joken.generate_and_sign(
        TestToken,
        %{"sub" => "user-123", "tenant_id" => "tenant-456", "nbf" => future},
        Joken.Signer.create("HS256", @secret)
      )

    assert {:error, :token_not_yet_valid} = TokenVerifier.verify(token)
  end
end
