defmodule RealtimePesaguardWeb.TenantChannel do
  use Phoenix.Channel

  # Default-deny until a canonical PesaGuard token verifier is wired into UserSocket.connect/3.
  @impl true
  def join("tenant:" <> _tenant_id, _params, _socket), do: {:error, %{reason: "unauthorized"}}
end
