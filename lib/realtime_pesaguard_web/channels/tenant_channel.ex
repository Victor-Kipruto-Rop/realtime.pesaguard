defmodule RealtimePesaguardWeb.TenantChannel do
  @moduledoc """
  Tenant channel placeholder. Authentication is performed by UserSocket; tenant
  membership authorization is completed in Phase 3. Joins remain denied here so
  authentication alone cannot grant access to tenant event streams.
  """

  use Phoenix.Channel

  @impl true
  def join("tenant:" <> _tenant_id, _payload, _socket), do: {:error, %{reason: "forbidden"}}
end
