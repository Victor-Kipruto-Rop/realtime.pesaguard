defmodule RealtimePesaguard.Messaging.EventHandler do
  @moduledoc """
  Kafka group-subscriber callback. Only the three documented browser event types
  can reach channels. Invalid and unapproved events are acknowledged but never
  broadcast. Transient PubSub failures terminate the subscriber before ack so
  Kafka can redeliver the message.
  """
  @behaviour :brod_group_subscriber
  require Logger

  alias RealtimePesaguard.Events.{Envelope, IdempotencyGuard}
  alias RealtimePesaguard.Realtime.Broadcaster

  @topic_events %{
    "pesaguard.transactions.failed" => "transaction.failed",
    "pesaguard.transactions.rejected" => "transaction.rejected",
    "pesaguard.fraud.analysis" => "fraud.analysis.started"
  }

  @impl true
  def init(_group_id, initial_state), do: {:ok, initial_state}

  @impl true
  def handle_message(topic, _partition, message, state) do
    case decode_message(message) do
      {:ok, value, headers} ->
        process_value(topic_name(topic), value, headers, state)

      {:error, reason} ->
        Logger.warning("Ignoring malformed broker message: #{inspect(reason)}")
        {:ok, :ack, state}
    end
  end

  defp process_value(topic, value, headers, state) do
    with {:ok, event} when is_map(event) <- Jason.decode(value),
         expected_type when is_binary(expected_type) <- Map.get(@topic_events, topic),
         true <- event["event_type"] == expected_type,
         :ok <- broker_identity_matches(event, headers) do
      case Envelope.validate(event) do
        {:ok, client_event} ->
          case deliver_or_raise(client_event) do
            :ok -> {:ok, :ack, state}
            :duplicate -> {:ok, :ack, state}
          end

        {:error, reason} ->
          Logger.warning("Broker event rejected by client contract: #{inspect(reason)}")
          {:ok, :ack, state}
      end
    else
      {:error, reason} ->
        Logger.warning("Broker event ignored: #{inspect(reason)}")
        {:ok, :ack, state}

      _ ->
        Logger.warning("Broker event ignored because its topic or event type is not approved")
        {:ok, :ack, state}
    end
  rescue
    _error ->
      Logger.warning("Broker event could not be processed; message will be retried")
      exit(:event_processing_failed)
  end

  defp broker_identity_matches(event, headers) do
    tenant_header = header_value(headers, "tenant_id")
    type_header = header_value(headers, "event_type")

    if tenant_header == event["tenant_id"] and type_header == event["event_type"] do
      :ok
    else
      {:error, :broker_metadata_mismatch}
    end
  end

  defp deliver_or_raise(event) do
    event_id = event["event_id"]
    tenant_id = event["tenant_id"]

    case IdempotencyGuard.claim(event_id, tenant_id) do
      :ok ->
        case deliver_with_retry(event, 1) do
          :ok ->
            case IdempotencyGuard.complete(event_id, tenant_id) do
              :ok -> :ok
              {:error, reason} ->
                Logger.error("Realtime idempotency completion failed: #{inspect(reason)}")
                exit(:idempotency_completion_failed)
            end

          {:error, reason} ->
            _ = IdempotencyGuard.release(event_id, tenant_id)
            Logger.error("Realtime event delivery failed after retries: #{inspect(reason)}")
            exit(:event_delivery_failed)
        end

      {:error, :duplicate} ->
        :duplicate

      {:error, reason} ->
        Logger.error("Realtime idempotency claim failed: #{inspect(reason)}")
        exit(:idempotency_claim_failed)
    end
  end

  defp deliver_with_retry(event, attempt) when attempt <= 3 do
    case Broadcaster.broadcast(event["tenant_id"], event) do
      :ok ->
        :ok

      {:error, _reason} when attempt < 3 ->
        Process.sleep(attempt * 200)
        deliver_with_retry(event, attempt + 1)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp decode_message({:kafka_message, _offset, _key, value, _ts_type, _timestamp, headers})
       when is_binary(value) and is_list(headers) do
    {:ok, value, headers}
  end

  defp decode_message(_), do: {:error, :invalid_message_record}

  defp header_value(headers, key) do
    binary_key = String.to_charlist(key)

    case List.keyfind(headers, binary_key, 0) || List.keyfind(headers, key, 0) do
      {_, value} when is_binary(value) -> value
      _ -> nil
    end
  end

  defp topic_name(topic) when is_list(topic), do: List.to_string(topic)
  defp topic_name(topic) when is_binary(topic), do: topic
  defp topic_name(_), do: ""
end
