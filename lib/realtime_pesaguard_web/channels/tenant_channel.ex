defmodule RealtimePesaguardWeb.TenantChannel do
  use Phoenix.Channel

  alias RealtimePesaguard.Tenants.AccessPolicy

  @impl true
  def join("tenant:" <> requested_tenant_id, _params, socket) do
    claims = socket.assigns[:verified_claims] || %{}

    case AccessPolicy.authorize_join(claims, requested_tenant_id) do
      :ok -> {:ok, socket}
      {:error, _reason} -> {:error, %{reason: "unauthorized"}}
    end
  end
end
