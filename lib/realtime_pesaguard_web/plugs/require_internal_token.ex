defmodule RealtimePesaguardWeb.Plugs.RequireInternalToken do
  @moduledoc "Reusable bearer-token gate for trusted service-to-service endpoints."
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    expected = Application.get_env(:realtime_pesaguard, :event_ingest_token)
    supplied =
      conn
      |> get_req_header("authorization")
      |> List.first()
      |> case do
        "Bearer " <> token -> token
        _ -> nil
      end

    if is_binary(expected) and expected != "" and secure_equal?(expected, supplied) do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized"}))
      |> halt()
    end
  end

  defp secure_equal?(a, b) when is_binary(b) and byte_size(a) == byte_size(b),
    do: Plug.Crypto.secure_compare(a, b)
  defp secure_equal?(_, _), do: false
end
