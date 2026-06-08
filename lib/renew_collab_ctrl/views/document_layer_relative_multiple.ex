defmodule RenewCollabCtrl.Views.DocumentLayerRelativeMultiple do
  defstruct [:document_id, :layer_id, :relative]

  def parse_relative("ancestors"), do: :ancestors
  def parse_relative("descendents"), do: :descendents
  def parse_relative("siblings_before"), do: {:siblings, :before}
  def parse_relative("siblings_after"), do: {:siblings, :after}
  def parse_relative("children"), do: :children
  def parse_relative("leafs"), do: :leafs
end
