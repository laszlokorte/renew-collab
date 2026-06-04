defmodule RenewCollabCtrl.Actions.DocumentEditReorderLayer do
  defstruct [:document_id, :layer_ids, :target_layer_id, :target]

  def parse_hierarchy_position("above", "inside"), do: {:above, :inside}
  def parse_hierarchy_position("above", "outside"), do: {:above, :outside}
  def parse_hierarchy_position("below", "outside"), do: {:below, :outside}
  def parse_hierarchy_position("below", "inside"), do: {:below, :inside}
end
