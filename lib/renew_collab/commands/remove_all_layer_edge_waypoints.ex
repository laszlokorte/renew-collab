defmodule RenewCollab.Commands.RemoveAllLayerEdgeWaypoints do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Bond
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint
  defstruct [:document_id, :layer_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.delete_all(
      :waypoint,
      fn
        %{edge: edge} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            select: w
          )
      end
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{edge: edge} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^edge.id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
