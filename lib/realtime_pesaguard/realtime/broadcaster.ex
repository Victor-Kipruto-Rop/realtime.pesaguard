defmodule RealtimePesaguard.Realtime.Broadcaster do
  @moduledoc """
  Tenant-scoped event broadcast helpers.

  Only validated events may reach this module. Topics match the exact transaction
  channel topic authorized by TenantChannel.
  """

  @tenant_id_pattern ~r/\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}\z/

  def broadcast(tenant_id, event)
      when is_binary(tenant_id) and is_map(event) do
    if valid_tenant_id?(tenant_id) and event["tenant_id"] == tenant_id do
      Phoenix.PubSub.broadcast(
        RealtimePesaguard.PubSub,
        tenant_topic(tenant_id),
        {:pesaguard_event, event}
      )
    else
      {:error, :invalid_tenant_scope}
    end
  end

  def broadcast(_tenant_id, _event), do: {:error, :invalid_event}

  def tenant_topic(tenant_id) when is_binary(tenant_id) do
    if valid_tenant_id?(tenant_id), do: "tenant:" <> tenant_id <> ":transactions", else: nil
  end

  defp valid_tenant_id?(tenant_id) when is_binary(tenant_id) do
    Regex.match?(@tenant_id_pattern, tenant_id)
  end
end
