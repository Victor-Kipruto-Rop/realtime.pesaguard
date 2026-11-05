defmodule RealtimePesaguard.Events.Envelope do
  @moduledoc """
  Strict client-delivery contract for events published by the canonical PesaGuard backend.

  This initial registry intentionally enables only three producer event types whose
  payloads have been inspected and can be minimized safely. Other producer event types
  remain rejected until their dashboard payload contracts are reviewed explicitly.
  """

  @max_event_bytes 65_536
  @event_version 1
  @schema_version "1.0"

  @required ~w(
    event_id event_type event_version schema_version tenant_id aggregate_id correlation_id payload
  )
  @allowed_fields ~w(
    event_id event_type event_version schema_version occurred_at timestamp tenant_id
    aggregate_id correlation_id payload request_id attempt max_attempts source
    source_event_id causation_id producer producer_version metadata
  )
  @client_fields ~w(
    event_id event_type event_version schema_version occurred_at tenant_id
    aggregate_id correlation_id payload
  )

  # Verified against pesaguard_backend_pipeline/fraud_events.py:
  # publish_fraud_analysis_started emits only transaction_id and model_version.
  @event_payload_schemas %{
    "fraud.analysis.started" => %{
      required: ~w(transaction_id model_version),
      allowed: ~w(transaction_id model_version)
    },
    "transaction.failed" => %{
      required: ~w(transaction_id state),
      allowed: ~w(transaction_id state),
      state: "FAILED"
    },
    "transaction.rejected" => %{
      required: ~w(transaction_id state),
      allowed: ~w(transaction_id state),
      state: "REJECTED"
    }
  }

  def validate(%{} = event) do
    with :ok <- validate_size(event),
         :ok <- validate_top_level(event),
         :ok <- validate_required(event),
         :ok <- validate_identifiers(event),
         :ok <- validate_version(event),
         {:ok, occurred_at} <- timestamp(event),
         :ok <- validate_payload(event) do
      {:ok,
       event
       |> Map.take(@client_fields)
       |> Map.put("occurred_at", occurred_at)
       |> Map.put(
         "payload",
         Map.take(event["payload"], @event_payload_schemas[event["event_type"]].allowed)
       )}
    end
  end

  def validate(_), do: {:error, :invalid_event}

  defp validate_size(event) do
    case Jason.encode(event) do
      {:ok, encoded} when byte_size(encoded) <= @max_event_bytes -> :ok
      {:ok, _encoded} -> {:error, :event_too_large}
      {:error, _reason} -> {:error, :invalid_event_encoding}
    end
  rescue
    _ -> {:error, :invalid_event_encoding}
  end

  defp validate_top_level(event) do
    if Enum.all?(Map.keys(event), &(&1 in @allowed_fields)) do
      :ok
    else
      {:error, :unknown_event_fields}
    end
  end

  defp validate_required(event) do
    missing = Enum.reject(@required, &Map.has_key?(event, &1))

    if missing == [], do: :ok, else: {:error, {:missing_fields, missing}}
  end

  defp validate_identifiers(event) do
    cond do
      not valid_string?(event["event_id"], 1, 160) ->
        {:error, :invalid_event_id}

      not is_binary(event["event_type"]) or byte_size(event["event_type"]) not in 1..120 ->
        {:error, :invalid_event_type}

      not valid_string?(event["tenant_id"], 1, 128) or
          not Regex.match?(~r/\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}\z/, event["tenant_id"]) ->
        {:error, :invalid_tenant_id}

      not valid_string?(event["aggregate_id"], 1, 160) ->
        {:error, :invalid_aggregate_id}

      not valid_string?(event["correlation_id"], 1, 160) ->
        {:error, :invalid_correlation_id}

      true ->
        :ok
    end
  end

  defp validate_version(event) do
    cond do
      event["event_version"] != @event_version ->
        {:error, :unsupported_event_version}

      event["schema_version"] != @schema_version ->
        {:error, :unsupported_schema_version}

      event["event_type"] not in Map.keys(@event_payload_schemas) ->
        {:error, :unsupported_event_type}

      true ->
        :ok
    end
  end

  defp timestamp(event) do
    value = event["occurred_at"] || event["timestamp"]

    if is_binary(value) do
      case DateTime.from_iso8601(value) do
        {:ok, datetime, 0} ->
          {:ok, DateTime.to_iso8601(datetime)}

        {:ok, _datetime, _offset} ->
          {:error, :timestamp_must_be_utc}

        {:error, _reason} ->
          {:error, :invalid_occurred_at}
      end
    else
      {:error, :invalid_occurred_at}
    end
  end

  defp validate_payload(event) do
    payload = event["payload"]
    schema = @event_payload_schemas[event["event_type"]]
    allowed = schema.allowed
    missing =
      if is_map(payload) do
        Enum.reject(schema.required, &Map.has_key?(payload, &1))
      else
        schema.required
      end

    cond do
      not is_map(payload) ->
        {:error, :invalid_payload}

      Enum.any?(Map.keys(payload), &(not is_binary(&1) or &1 not in allowed)) ->
        {:error, :unknown_payload_fields}

      missing != [] ->
        {:error, {:missing_payload_fields, missing}}

      not valid_string?(payload["transaction_id"], 1, 160) ->
        {:error, :invalid_payload_transaction_id}

      event["event_type"] == "fraud.analysis.started" and
          not valid_string?(payload["model_version"], 1, 80) ->
        {:error, :invalid_payload_model_version}

      Map.has_key?(schema, :state) and payload["state"] != schema.state ->
        {:error, :invalid_payload_state}

      true ->
        :ok
    end
  end

  defp valid_string?(value, min, max) do
    is_binary(value) and byte_size(value) in min..max and String.trim(value) != ""
  end
end
