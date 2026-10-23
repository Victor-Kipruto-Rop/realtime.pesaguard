defmodule RealtimePesaguardWeb.UserSocket do
  use Phoenix.Socket

  channel "tenant:*", RealtimePesaguardWeb.TenantChannel

  @impl true
  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(_socket), do: nil
end
