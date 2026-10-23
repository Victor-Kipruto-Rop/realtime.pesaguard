defmodule RealtimePesaguardWeb.Serializers.EventSerializer do
  @moduledoc "Allow-list boundary for event payloads sent to browser clients."

  # TODO: define versioned payload schemas with the PesaGuard backend team.
  # Keep this deny-by-default until each event type has a reviewed serializer.
  def serialize(_event), do: {:error, :serializer_not_configured}
end
