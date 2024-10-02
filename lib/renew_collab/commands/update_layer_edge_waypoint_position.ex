defmodule RenewCollab.Commands.UpdateLayerEdgeWaypointPosition do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :waypoint_id, :new_position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id,
        new_position: new_position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: new_position
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id,
        new_position: new_position
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
    |> Ecto.Multi.update(
      :size,
      fn %{waypoint: waypoint} ->
        Waypoint.change_position(waypoint, new_position)
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^waypoint.edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
