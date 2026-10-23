defmodule RealtimePesaguard.Accounts.TokenVerifier do
  @moduledoc """
  Verifies canonical PesaGuard HS256 access tokens and asks the canonical API
  to validate live session, revocation, account status and authorization state.
  Both checks are required; local signature verification alone is insufficient.
  """

  use Joken.Config

  @callback verify(binary()) :: {:ok, map()} | {:error, atom()}
  @max_token_bytes 16_384
  @identifier_max_bytes 160

  @impl Joken.Config
  def token_config do
    default_claims(
      iss: configured(:jwt_issuer),
      aud: configured(:jwt_audience),
      default_exp: 900
    )
    |> add_claim("sub", nil, &valid_identifier?/1)
    |> add_claim("tenant_id", nil, &valid_identifier?/1)
  end

  @spec verify(binary()) :: {:ok, map()} | {:error, atom()}
  def verify(token) when is_binary(token) and byte_size(token) in 1..@max_token_bytes do
    with {:ok, signer} <- configured_signer(),
         {:ok, claims} <- verify_signed_token(token, signer),
         :ok <- validate_canonical_claims(claims),
         {:ok, identity} <- backend_auth_client().validate(token),
         :ok <- validate_backend_identity(claims, identity) do
      {:ok,
       Map.merge(
         Map.take(claims, [
           "sub", "tenant_id", "iss", "aud", "exp", "nbf", "iat", "jti",
           "auth_version", "scope", "type"
         ]),
         %{"roles" => identity["roles"] || [], "permissions" => identity["permissions"] || []}
       )}
    else
      {:error, reason} -> {:error, normalize_error(reason)}
    end
  rescue
    _ -> {:error, :identity_validation_unavailable}
  end

  def verify(token) when is_binary(token), do: {:error, :invalid_token}
  def verify(_), do: {:error, :invalid_token}

  defp verify_signed_token(token, signer) do
    case Joken.verify_and_validate(__MODULE__, token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, _} -> {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :invalid_token}
  end

  defp configured_signer do
    secret = configured(:jwt_hs256_secret)
    issuer = configured(:jwt_issuer)
    audience = configured(:jwt_audience)

    cond do
      not non_empty_binary?(secret) or byte_size(secret) < 32 ->
        {:error, :identity_verifier_not_configured}
      not non_empty_binary?(issuer) or not non_empty_binary?(audience) ->
        {:error, :identity_verifier_not_configured}
      true ->
        {:ok, Joken.Signer.create("HS256", secret)}
    end
  rescue
    _ -> {:error, :identity_verifier_not_configured}
  end

  defp validate_canonical_claims(claims) do
    now = System.system_time(:second)

    required =
      Enum.all?(["sub", "tenant_id", "iss", "aud", "exp", "iat", "nbf", "jti",
        "type", "auth_version", "scope"], &Map.has_key?(claims, &1))

    cond do
      not required -> {:error, :missing_required_claims}
      claims["type"] != "access" -> {:error, :invalid_token_type}
      not is_integer(claims["iat"]) or not is_integer(claims["nbf"]) or not is_integer(claims["exp"]) ->
        {:error, :invalid_token}
      claims["nbf"] > now -> {:error, :token_not_yet_valid}
      claims["iat"] > now + 30 -> {:error, :invalid_token}
      claims["exp"] <= now - 30 -> {:error, :invalid_token}
      not valid_identifier?(claims["jti"]) -> {:error, :missing_required_claims}
      not is_integer(claims["auth_version"]) or claims["auth_version"] < 1 ->
        {:error, :missing_required_claims}
      not is_binary(claims["scope"]) or byte_size(claims["scope"]) > 4096 ->
        {:error, :missing_required_claims}
      true -> :ok
    end
  end

  defp validate_backend_identity(claims, identity) when is_map(identity) do
    cond do
      not valid_identifier?(identity["user_id"]) -> {:error, :invalid_token}
      identity["tenant_id"] != claims["tenant_id"] -> {:error, :invalid_token}
      true -> :ok
    end
  end
  defp validate_backend_identity(_, _), do: {:error, :invalid_token}

  defp backend_auth_client do
    Application.get_env(
      :realtime_pesaguard,
      :backend_auth_client,
      RealtimePesaguard.Accounts.BackendAuthClient
    )
  end

  defp valid_identifier?(value) do
    is_binary(value) and byte_size(value) in 1..@identifier_max_bytes and
      String.trim(value) == value and String.trim(value) != ""
  end

  defp configured(key), do: Application.get_env(:realtime_pesaguard, key)
  defp non_empty_binary?(value), do: is_binary(value) and String.trim(value) != ""

  defp normalize_error(:identity_verifier_not_configured), do: :identity_verifier_not_configured
  defp normalize_error(:identity_validation_unavailable), do: :identity_validation_unavailable
  defp normalize_error(:missing_required_claims), do: :missing_required_claims
  defp normalize_error(:invalid_token_type), do: :invalid_token
  defp normalize_error(:token_not_yet_valid), do: :token_not_yet_valid
  defp normalize_error(_), do: :invalid_token
end
