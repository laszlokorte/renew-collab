defmodule RenewCollabCtrl.Actions.DocumentEditReorderLayerRelative do
  defstruct [:document_id, :layer_id, :relative_direction, :target]

  def parse_direction("before_parent"), do: {:parent, {:below, :outside}}
  def parse_direction("after_parent"), do: {:parent, {:above, :outside}}
  def parse_direction("frontwards"), do: {{:sibling, :next}, {:above, :outside}}
  def parse_direction("backwards"), do: {{:sibling, :prev}, {:below, :outside}}
  def parse_direction("to_front"), do: {{:sibling, :last}, {:above, :outside}}
  def parse_direction("to_back"), do: {{:sibling, :first}, {:below, :outside}}
  def parse_direction("into_prev"), do: {{:sibling, :prev}, {:above, :inside}}
end
