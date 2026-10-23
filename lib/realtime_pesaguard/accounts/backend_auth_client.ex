defmodule RealtimePesaguard.Accounts.BackendAuthClient do
  @moduledoc """
  Validates a bearer token against the canonical API's GET /auth/verify route.
  This call is required to enforce persisted session, revocation and account state.
  """

  @max_response_bytes 65_536

  def validate(token) when is_binary(token) do
    with {:ok, url} <- configured_url(),
         request <- Finch.build(:get, url, [
           {"authorization", "Bearer " <> token},
           {"accept", "application/json"}
         ]),
         {:ok, response} <- Finch.request(request, RealtimePesaguard.Finch,
           receive_timeout: 2_500,
           pool_timeout: 1_000
         ),
         {:ok, identity} <- parse_response(response) do
      {:ok, identity}
    else
      {:error, :invalid_token} = error -> error
      {:error, _reason} -> {:error, :identity_validation_unavailable}
    end
  rescue
    _ -> {:error, :identity_validation_unavailable}
  end

  def validate(_), do: {:error, :invalid_token}

  defp configured_url do
    case Application.get_env(:realtime_pesaguard, :auth_validation_url) do
      url when is_binary(url) and byte_size(url) > 0 ->
        uri = URI.parse(url)
        if uri.scheme == "https" and is_binary(uri.host) do
          {:ok, url}
        else
          {:error, :identity_verifier_not_configured}
        end
      _ ->
        {:error, :identity_verifier_not_configured}
    end
  end

  defp parse_response(%Finch.Response{status: 200, body: body})
       when is_binary(body) and byte_size(body) <= @max_response_bytes do
    case Jason.decode(body) do
      {:ok, %{"user_id" => user_id, "tenant_id" => tenant_id} = identity}
      when is_binary(user_id) and is_binary(tenant_id) ->
        {:ok, identity}
      _ ->
        {:error, :invalid_token}
    end
  end

  defp parse_response(%Finch.Response{status: status}) when status in [401, 403],
    do: {:error, :invalid_token}

  defp parse_response(_), do: {:error, :identity_validation_unavailable}
end
