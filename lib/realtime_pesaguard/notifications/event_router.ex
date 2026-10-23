defmodule RealtimePesaguard.Notifications.EventRouter do
  @moduledoc "Maps validated, allow-listed event types to safe notification payloads."

  @supported_types ~w(reconciliation.updated risk.alert_created datasource.health_changed security.activity_recorded)

  def supported_type?(type) when is_binary(type), do: type in @supported_types
  def supported_type?(_), do: false
end
