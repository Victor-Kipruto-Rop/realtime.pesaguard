defmodule RealtimePesaguardWeb.UserSocket do
  @moduledoc """
  Authenticates dashboard socket connections with a short-lived PesaGuard access token.

  Browser Phoenix clients pass the token as the `token` socket param over WSS.
  Keep access tokens short-lived and ensure reverse-proxy/access logs redact query
  strings. Do not put tokens in application logs or analytics.
  """

  use Phoenix.Socket, max_channels_per_transport: 5

  alias RealtimePesaguard.Accounts.{SocketSessionMonitor, TokenVerifier}
  alias RealtimePesaguard.Security.RateLimiter

  channel "tenant:*", RealtimePesaguardWeb.TenantChannel

  @connect_limit 30
  @window_ms 60_000

  @impl true
  def connect(%{"token" => token}, socket, connect_info) when is_binary(token) do
    with ip when is_binary(ip) <- RateLimiter.client_ip(connect_info),
         true <- RateLimiter.allow?(:socket_connect, ip, @connect_limit, @window_ms),
         {:ok, claims} <- TokenVerifier.verify(token),
         subject when is_binary(subject) <- claims["sub"],
         :ok <- SocketSessionMonitor.register(token, subject, self()) do
      {:ok,
       socket
       |> assign(:verified_claims, claims)
       |> assign(:client_ip, ip)}
    else
      _ -> :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(%{assigns: %{verified_claims: %{"sub" => subject}}}) when is_binary(subject) do
    "user_socket:#{subject}"
  end

  def id(_socket), do: nil
end
