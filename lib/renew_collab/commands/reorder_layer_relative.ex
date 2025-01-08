defmodule RenewCollab.Commands.ReorderLayerRelative do
  import Ecto.Query, warn: false

  defstruct [:document_id, :layer_id, :relative_direction, :target]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        relative_direction: relative_direction,
        target: {order, relative}
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      relative_direction: relative_direction,
      target: {order, relative}
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        relative_direction: relative_direction,
        target: target
      }) do
    RenewCollab.Queries.LayerHierarchyRelative.new(%{
      document_id: document_id,
      layer_id: layer_id,
      id_only: true,
      relative: relative_direction
    })
    |> RenewCollab.Queries.LayerHierarchyRelative.multi()
    |> Ecto.Multi.run(:valid_move, fn
      _, %{result: nil} ->
        {:error, :not_valid}

      _, %{result: _target_id} ->
        {:ok, true}
    end)
    |> Ecto.Multi.merge(fn
      %{result: target_id} ->
        RenewCollab.Commands.ReorderLayer.new(%{
          document_id: document_id,
          layer_id: layer_id,
          target_layer_id: target_id,
          target: target
        })
        |> RenewCollab.Commands.ReorderLayer.multi()
    end)
  end

  def parse_direction("before_parent"), do: {:parent, {:below, :outside}}
  def parse_direction("after_parent"), do: {:parent, {:above, :outside}}
  def parse_direction("frontwards"), do: {{:sibling, :next}, {:above, :outside}}
  def parse_direction("backwards"), do: {{:sibling, :prev}, {:below, :outside}}
  def parse_direction("to_front"), do: {{:sibling, :last}, {:above, :outside}}
  def parse_direction("to_back"), do: {{:sibling, :first}, {:below, :outside}}
  def parse_direction("into_prev"), do: {{:sibling, :prev}, {:above, :inside}}
end
