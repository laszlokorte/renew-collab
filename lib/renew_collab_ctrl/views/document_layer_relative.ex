defmodule RenewCollabCtrl.Views.DocumentLayerRelative do
  defstruct [:document_id, :layer_id, :relative, :id_only]

  def parse_relative("parent"), do: :parent
  def parse_relative("sibling_first"), do: {:sibling, :first}
  def parse_relative("sibling_last"), do: {:sibling, :last}
  def parse_relative("sibling_prev"), do: {:sibling, :prev}
  def parse_relative("sibling_next"), do: {:sibling, :next}
  def parse_relative("child_first"), do: {:child, :first}
  def parse_relative("child_last"), do: {:child, :last}
end
