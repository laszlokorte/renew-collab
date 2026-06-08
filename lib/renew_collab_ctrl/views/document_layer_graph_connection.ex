defmodule RenewCollabCtrl.Views.DocumentLayerGraphConnection do
  defstruct [:document_id, :layer_id, :rel]

  def parse_relative("incoming"), do: :incoming
  def parse_relative("outcoming"), do: :outcoming
  def parse_relative("source"), do: :source
  def parse_relative("target"), do: :target
  def parse_relative("nodes"), do: :nodes
  def parse_relative("edges"), do: :edges
end
