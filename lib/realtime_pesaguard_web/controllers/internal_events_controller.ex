defmodule RealtimePesaguardWeb.InternalEventsController do
  use Phoenix.Controller, formats: [:json], layouts: []
  alias RealtimePesaguard.Events.Envelope
  alias RealtimePesaguard.Realtime.Broadcaster

  def create(conn, params) do
    enabled? = Application.get_env(:realtime_pesaguard, :event_ingest_enabled, false)
    expected = Application.get_env(:realtime_pesaguard, :event_ingest_token)
    supplied = conn |> get_req_header("authorization") |> List.first() |> bearer_token()

    cond do
      not enabled? ->
        conn |> put_status(:service_unavailable) |> json(%{error: "event_ingest_disabled"})

      not is_binary(expected) or expected == "" ->
        conn |> put_status(:service_unavailable) |> json(%{error: "event_ingest_not_configured"})

      not secure_equal?(expected, supplied) ->
        conn |> put_status(:unauthorized) |> json(%{error: "unauthorized"})

      true ->
        with {:ok, event} <- Envelope.validate(params) do
          # This route is for trusted backend-to-gateway delivery only. The caller must
          # derive tenant_id from its authenticated tenant context, never user input.
          :ok = Broadcaster.broadcast(event["tenant_id"], event)
          conn |> put_status(:accepted) |> json(%{accepted: true, event_id: event["event_id"]})
        else
          {:error, _reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_event"})
        end
    end
  end

  defp bearer_token("Bearer " <> token), do: token
  defp bearer_token(_), do: nil

  defp secure_equal?(expected, supplied)
       when is_binary(supplied) and byte_size(expected) == byte_size(supplied) do
    Plug.Crypto.secure_compare(expected, supplied)
  end

  defp secure_equal?(_, _), do: false
end
