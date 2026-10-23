defmodule RealtimePesaguard.Accounts.TokenVerifier do
  @moduledoc """
  Verifies short-lived PesaGuard access JWTs using a configured HS256 shared secret.

  This adapter is intentionally fail-closed. It does not decode unverified JWT
  claims, accept algorithm negotiation from the token header, or provide a
  development bypass. Configure it only if the canonical PesaGuard issuer is
  confirmed to issue HS256 tokens with the claim contract documented here.
  Asymmetric/JWKS issuers require a separate verified adapter; do not copy a
  public key into the shared-secret setting.
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

  @doc """
  Verifies signature and standard claims, then returns only the claims the
  gateway needs. The tenant identifier is accepted only from this verified
  token, never from WebSocket query parameters.
  """
  @spec verify(binary()) :: {:ok, map()} | {:error, atom()}
  def verify(token) when is_binary(token) and byte_size(token) in 1..@max_token_bytes do
    with {:ok, signer} <- configured_signer(),
         {:ok, claims} <- verify_signed_token(token, signer),
         :ok <- validate_not_before(claims),
         :ok <- validate_identity_claims(claims) do
      {:ok, Map.take(claims, ["sub", "tenant_id", "iss", "aud", "exp", "nbf", "iat", "jti", "roles"])}
    else
      {:error, reason} -> {:error, normalize_error(reason)}
    end
  end

  def verify(token) when is_binary(token), do: {:error, :invalid_token}
  def verify(_), do: {:error, :invalid_token}

  defp verify_signed_token(token, signer) do
    case Joken.verify_and_validate(__MODULE__, token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, _reason} -> {:error, :invalid_token}
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

      not non_empty_binary?(issuer) ->
        {:error, :identity_verifier_not_configured}

      not non_empty_binary?(audience) ->
        {:error, :identity_verifier_not_configured}

      true ->
        {:ok, Joken.Signer.create("HS256", secret)}
    end
  rescue
    _ -> {:error, :identity_verifier_not_configured}
  end

  defp validate_not_before(%{"nbf" => not_before}) when is_integer(not_before) do
    if not_before <= System.system_time(:second), do: :ok, else: {:error, :token_not_yet_valid}
  end

  defp validate_not_before(%{"nbf" => _}), do: {:error, :invalid_token}
  defp validate_not_before(_claims), do: :ok

  defp validate_identity_claims(claims) do
    if valid_identifier?(claims["sub"]) and valid_identifier?(claims["tenant_id"]) do
      :ok
    else
      {:error, :missing_required_claims}
    end
  end

  defp valid_identifier?(value) do
    is_binary(value) and byte_size(value) in 1..@identifier_max_bytes and
      String.trim(value) == value and String.trim(value) != ""
  end

  defp configured(key), do: Application.get_env(:realtime_pesaguard, key)
  defp non_empty_binary?(value), do: is_binary(value) and String.trim(value) != ""

  defp normalize_error(:identity_verifier_not_configured), do: :identity_verifier_not_configured
  defp normalize_error(:missing_required_claims), do: :missing_required_claims
  defp normalize_error(:token_not_yet_valid), do: :token_not_yet_valid
  defp normalize_error(_), do: :invalid_token
end
