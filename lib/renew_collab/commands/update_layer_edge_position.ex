defmodule RenewCollab.Commands.UpdateLayerEdgePosition do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Edge
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Bond
  defstruct [:document_id, :layer_id, :new_position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :position,
      fn %{edge: edge} ->
        Edge.change_position(edge, new_position)
      end
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{edge: edge} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^edge.id,
          group_by: bond.id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
