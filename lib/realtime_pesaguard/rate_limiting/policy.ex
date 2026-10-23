defmodule RealtimePesaguard.RateLimiting.Policy do
  @moduledoc "Rate limit policy constants; enforcement adapter remains to be implemented."

  def defaults do
    %{socket_connects_per_minute: 30, internal_events_per_minute: 600, max_event_bytes: 65_536}
  end
end
