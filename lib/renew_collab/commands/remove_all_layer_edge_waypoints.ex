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
      :affected_bonds,
      fn %{edge: edge} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^edge.id,
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
