defmodule RealtimePesaguard.Integrations.KafkaAdapter do
  @moduledoc """
  Kafka/Redpanda adapter boundary.

  TODO: select and configure the supported client only after broker version,
  authentication, topic names, schemas, and offset/retry semantics are confirmed.
  """

  def start_link(_opts), do: {:error, :broker_adapter_not_configured}
end
