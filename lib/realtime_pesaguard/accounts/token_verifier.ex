defmodule RealtimePesaguard.Accounts.TokenVerifier do
  @moduledoc """
  Delegates access-token verification to the canonical PesaGuard API.

  The API is the authority for signature/key rotation, required JWT claims,
  session activity, revocation, account state and authorization version. The
  gateway deliberately does not duplicate issuer key management or trust
  client-decoded JWT claims.
  """

  @callback verify(binary()) :: {:ok, map()} | {:error, atom()}
  @max_token_bytes 16_384

  @spec verify(binary()) :: {:ok, map()} | {:error, atom()}
  def verify(token) when is_binary(token) and byte_size(token) in 1..@max_token_bytes do
    case backend_auth_client().validate(token) do
      {:ok, %{"user_id" => user_id, "tenant_id" => tenant_id} = identity}
      when is_binary(user_id) and byte_size(user_id) in 1..160 and
             is_binary(tenant_id) and byte_size(tenant_id) in 1..160 ->
        {:ok,
         %{
           "sub" => user_id,
           "tenant_id" => tenant_id,
           "roles" => safe_list(identity["roles"]),
           "permissions" => safe_list(identity["permissions"])
         }}

      {:error, :invalid_token} ->
        {:error, :invalid_token}

      {:error, _reason} ->
        {:error, :identity_validation_unavailable}

      _ ->
        {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :identity_validation_unavailable}
  end

  def verify(token) when is_binary(token), do: {:error, :invalid_token}
  def verify(_), do: {:error, :invalid_token}

  defp backend_auth_client do
    Application.get_env(
      :realtime_pesaguard,
      :backend_auth_client,
      RealtimePesaguard.Accounts.BackendAuthClient
    )
  end

  defp safe_list(values) when is_list(values) do
    if Enum.all?(values, &is_binary/1), do: values, else: []
  end

  defp safe_list(_), do: []
end
