defmodule RealtimePesaguard.Realtime.Broadcaster do
  @moduledoc "Tenant-scoped event broadcast helpers."

  def broadcast(tenant_id, event) when is_binary(tenant_id) and is_map(event) do
    Phoenix.PubSub.broadcast(
      RealtimePesaguard.PubSub,
      tenant_topic(tenant_id),
      {:pesaguard_event, event}
    )
  end

  def tenant_topic(tenant_id) when is_binary(tenant_id), do: "tenant:" <> tenant_id
end
