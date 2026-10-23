defmodule RealtimePesaguard.Messaging.Consumer do
  @moduledoc """
  Kafka/Redpanda consumer boundary.

  Not started until the real broker, topic, schema, offset, retry, and dead-letter
  contracts are configured. Do not invent production topic names.
  """

  def configured?, do: false
end
