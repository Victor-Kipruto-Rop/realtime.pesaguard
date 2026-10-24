defmodule RealtimePesaguardWeb.TenantChannel do
  @moduledoc """
  Authorizes tenant-scoped transaction subscriptions using identity validated by
  the canonical PesaGuard API. This channel transports events only; it does not
  perform financial operations.
  """

  use Phoenix.Channel
  require Logger

  alias RealtimePesaguard.Security.RateLimiter

  @required_permission "read:transactions"
  @tenant_id_pattern ~r/\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}\z/
  @join_limit 60
  @window_ms 60_000

  @impl true
  def join(topic, _params, socket) do
    claims = socket.assigns[:verified_claims]
    subject = if is_map(claims), do: claims["sub"], else: nil

    result =
      with true <- is_binary(subject),
           true <- RateLimiter.allow?(:channel_join, subject, @join_limit, @window_ms),
           :ok <- authorize(topic, claims) do
        :ok
      else
        false -> {:error, "join_rate_limit_or_identity_unavailable"}
        {:error, reason} -> {:error, reason}
      end

    case result do
      :ok ->
        {:ok, socket}

      {:error, reason} ->
        # Deliberately do not log tenant/user identifiers, client params or claims.
        Logger.warning("Tenant channel join denied: #{reason}")
        {:error, %{reason: "unauthorized"}}
    end
  end

  defp authorize(topic, claims) when is_binary(topic) and is_map(claims) do
    with {:ok, requested_tenant_id} <- parse_topic(topic),
         {:ok, authenticated_tenant_id} <- tenant_id_from_claims(claims),
         :ok <- match_tenant(requested_tenant_id, authenticated_tenant_id),
         :ok <- require_transaction_permission(claims) do
      :ok
    end
  end

  defp authorize(_topic, _claims), do: {:error, "missing_verified_identity"}

  defp parse_topic(topic) do
    case String.split(topic, ":", trim: false) do
      ["tenant", tenant_id, "transactions"] ->
        if valid_tenant_id?(tenant_id) do
          {:ok, tenant_id}
        else
          {:error, "invalid_tenant_id"}
        end

      _ ->
        {:error, "unsupported_topic"}
    end
  end

  defp tenant_id_from_claims(%{"tenant_id" => tenant_id}) when is_binary(tenant_id) do
    if valid_tenant_id?(tenant_id) do
      {:ok, tenant_id}
    else
      {:error, "invalid_verified_tenant_id"}
    end
  end

  defp tenant_id_from_claims(_claims), do: {:error, "missing_verified_tenant_id"}

  defp match_tenant(requested, authenticated) when requested == authenticated, do: :ok
  defp match_tenant(_requested, _authenticated), do: {:error, "tenant_mismatch"}

  defp require_transaction_permission(%{"permissions" => permissions})
       when is_list(permissions) do
    if Enum.all?(permissions, &is_binary/1) and @required_permission in permissions do
      :ok
    else
      {:error, "missing_or_malformed_permission"}
    end
  end

  defp require_transaction_permission(_claims), do: {:error, "missing_or_malformed_permission"}

  defp valid_tenant_id?(tenant_id) when is_binary(tenant_id) do
    Regex.match?(@tenant_id_pattern, tenant_id)
  end

  defp valid_tenant_id?(_tenant_id), do: false
end
