defmodule RenewCollab.Commands.DeleteLayerEdgeWaypoint do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Bond

  defstruct [:document_id, :layer_id, :waypoint_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.delete(
      :deletion,
      fn %{waypoint: waypoint} ->
        waypoint
      end
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^waypoint.edge_id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
