defmodule RenewCollab.Commands.CreateLayerEdgeWaypoint do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Bond

  defstruct [:document_id, :layer_id, :prev_waypoint_id, :position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        prev_waypoint_id: prev_waypoint_id,
        position: position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: position
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        prev_waypoint_id: prev_waypoint_id,
        position: position
      }) do
    set_position =
      case position do
        {x, y} ->
          %{
            position_x: x,
            position_y: y
          }

        nil ->
          %{
            document_id: document_id,
            layer_id: layer_id,
            prev_waypoint_id: prev_waypoint_id,
            position: position
          }
      end

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      if is_nil(prev_waypoint_id) do
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w2 in assoc(e, :waypoints),
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: e.id,
          limit: 1,
          select: {e, nil, w2, max(w3.sort)}
        )
      else
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w in assoc(e, :waypoints),
          on: w.id == ^prev_waypoint_id,
          left_join: w2 in assoc(e, :waypoints),
          on: w2.sort > w.sort,
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: e.id,
          limit: 1,
          select: {e, w, w2, max(w3.sort)}
        )
      end
    )
    |> Ecto.Multi.update_all(
      :increment_future_waypoints,
      fn
        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: 1 + ^max_sort * 2]]
          )

        %{edge: {edge, prev_waypoint_id, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint_id.sort,
            update: [inc: [sort: 1 + ^max_sort * 2]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :offset_waypoints,
      fn
        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: -(^max_sort) * 2]]
          )

        %{edge: {edge, prev_waypoint_id, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint_id.sort,
            update: [inc: [sort: -(^max_sort) * 2]]
          )
      end,
      []
    )
    |> Ecto.Multi.insert(
      :waypoint,
      fn
        %{edge: {edge, nil, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: (edge.source_x + edge.target_x) / 2,
            position_y: (edge.source_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: prev_waypoint.sort + 1,
            position_x: (prev_waypoint.position_x + edge.target_x) / 2,
            position_y: (prev_waypoint.position_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, nil, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + edge.source_x) / 2,
            position_y: (next_waypoint.position_y + edge.source_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + prev_waypoint.position_x) / 2,
            position_y: (next_waypoint.position_y + prev_waypoint.position_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)
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
