defmodule RealtimePesaguardWeb.InternalEventsController do
  use Phoenix.Controller, formats: [:json], layouts: []
  alias RealtimePesaguard.Events.Envelope
  alias RealtimePesaguard.Events.IdempotencyGuard
  alias RealtimePesaguard.Realtime.Broadcaster
  alias RealtimePesaguard.Security.RateLimiter

  def create(conn, params) do
    enabled? = Application.get_env(:realtime_pesaguard, :event_ingest_enabled, false)
    expected = Application.get_env(:realtime_pesaguard, :event_ingest_token)
    supplied = conn |> get_req_header("authorization") |> List.first() |> bearer_token()

    cond do
      not enabled? ->
        conn |> put_status(:service_unavailable) |> json(%{error: "event_ingest_disabled"})

      not RateLimiter.allow?(:internal_event, conn.remote_ip || :unknown, 120, 60_000) ->
        conn |> put_status(:too_many_requests) |> json(%{error: "rate_limited"})

      not is_binary(expected) or expected == "" ->
        conn |> put_status(:service_unavailable) |> json(%{error: "event_ingest_not_configured"})

      not secure_equal?(expected, supplied) ->
        conn |> put_status(:unauthorized) |> json(%{error: "unauthorized"})

      true ->
        case Envelope.validate(params) do
          {:ok, event} ->
            # Schema validation does not authenticate tenant ownership. Keep this route
            # disabled until producer identity and trusted tenant derivation are approved.
            case IdempotencyGuard.claim(event["event_id"], event["tenant_id"]) do
              :ok ->
                deliver_event(conn, event)

              {:error, :duplicate} ->
                conn |> put_status(:conflict) |> json(%{error: "duplicate_event"})

              {:error, :event_id_conflict} ->
                conn |> put_status(:conflict) |> json(%{error: "event_id_conflict"})

              {:error, _reason} ->
                conn
                |> put_status(:service_unavailable)
                |> json(%{error: "event_ingest_unavailable"})
            end

          {:error, _reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_event"})
        end
    end
  end

  defp deliver_event(conn, event) do
    case Broadcaster.broadcast(event["tenant_id"], event) do
      :ok ->
        case IdempotencyGuard.complete(event["event_id"], event["tenant_id"]) do
          :ok ->
            conn
            |> put_status(:accepted)
            |> json(%{accepted: true, event_id: event["event_id"]})

          {:error, _reason} ->
            conn
            |> put_status(:service_unavailable)
            |> json(%{error: "event_delivery_state_unavailable"})
        end

      {:error, reason} when reason in [:invalid_tenant_scope, :invalid_event] ->
        :ok = IdempotencyGuard.release(event["event_id"], event["tenant_id"])
        conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_event"})

      {:error, _reason} ->
        :ok = IdempotencyGuard.release(event["event_id"], event["tenant_id"])
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "event_delivery_unavailable"})
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
