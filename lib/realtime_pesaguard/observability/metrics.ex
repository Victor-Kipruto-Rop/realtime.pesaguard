defmodule RealtimePesaguard.Observability.Metrics do
  @moduledoc "Metrics definitions will be added with the deployment's agreed telemetry backend."

  def definitions do
    [
      {:counter, "gateway_events_accepted"},
      {:counter, "gateway_events_rejected"},
      {:counter, "gateway_channel_join_denied"},
      {:distribution, "gateway_broadcast_duration"}
    ]
  end
end
