defmodule RenewCollabCtrl.Views.DocumentLayerReachable do
  defstruct [:document_id, :layer_id, :downlink, :uplink]

  def parse_direction("all"), do: %{downlink: true, uplink: true}
  def parse_direction("downlink"), do: %{downlink: true, uplink: false}
  def parse_direction("uplink"), do: %{downlink: false, uplink: true}
end
