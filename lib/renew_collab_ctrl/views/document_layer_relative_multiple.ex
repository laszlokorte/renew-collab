defmodule RenewCollabCtrl.Views.DocumentLayerRelativeMultiple do
  defstruct [:document_id, :layer_id, :rel]

  def parse_relative("root"), do: :root
  def parse_relative("ancestors"), do: :ancestors
  def parse_relative("deep_children"), do: :descendants
  def parse_relative("direct_children"), do: :children
  def parse_relative("leafs"), do: :leafs
  def parse_relative("siblings"), do: {:siblings, :all}
  def parse_relative("siblings_before"), do: {:siblings, :before}
  def parse_relative("siblings_after"), do: {:siblings, :after}
end
