defmodule RealtimePesaguard.Events.Envelope do
  @moduledoc "Validation for the minimal, versionable event envelope accepted by the gateway."

  @required ~w(event_id event_type occurred_at tenant_id payload)

  def validate(%{} = event) do
    missing = Enum.reject(@required, &Map.has_key?(event, &1))

    cond do
      missing != [] ->
        {:error, {:missing_fields, missing}}

      not is_binary(event["event_id"]) or byte_size(event["event_id"]) not in 1..160 ->
        {:error, :invalid_event_id}

      not is_binary(event["event_type"]) or byte_size(event["event_type"]) not in 1..120 ->
        {:error, :invalid_event_type}

      not is_binary(event["tenant_id"]) or byte_size(event["tenant_id"]) not in 1..160 ->
        {:error, :invalid_tenant_id}

      not is_binary(event["occurred_at"]) ->
        {:error, :invalid_occurred_at}

      not is_map(event["payload"]) ->
        {:error, :invalid_payload}

      true ->
        {:ok, Map.take(event, @required)}
    end
  end

  def validate(_), do: {:error, :invalid_event}
end
