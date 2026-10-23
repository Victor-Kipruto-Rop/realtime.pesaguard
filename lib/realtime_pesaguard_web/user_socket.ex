defmodule RealtimePesaguardWeb.UserSocket do
  @moduledoc """
  Authenticates dashboard socket connections with a short-lived PesaGuard access token.

  Browser Phoenix clients pass the token as the `token` socket param over WSS.
  Keep access tokens short-lived and ensure reverse-proxy/access logs redact query
  strings. Do not put tokens in application logs or analytics.
  """

  use Phoenix.Socket

  alias RealtimePesaguard.Accounts.TokenVerifier

  channel "tenant:*", RealtimePesaguardWeb.TenantChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) when is_binary(token) do
    case TokenVerifier.verify(token) do
      {:ok, claims} ->
        {:ok, assign(socket, :verified_claims, claims)}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(%{assigns: %{verified_claims: %{"sub" => subject}}}) when is_binary(subject) do
    "user_socket:#{subject}"
  end

  def id(_socket), do: nil
end
