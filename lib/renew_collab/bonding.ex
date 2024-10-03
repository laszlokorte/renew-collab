defmodule RenewCollab.Bonding do
  import Ecto.Query, warn: false
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Element.Edge

  def reposition_multi() do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :affected_waypoints,
      fn %{affected_bonds: affected_bonds} ->
        from(w in Waypoint,
          where: w.edge_id in ^Enum.map(affected_bonds, & &1.bond.element_edge_id),
          order_by: [asc: w.sort]
        )
      end
    )
    |> Ecto.Multi.run(
      :update_edge_points,
      fn repo,
         %{
           affected_bonds: affected_bonds,
           affected_waypoints: affected_waypoints
         } ->
        waypoint_map = Enum.group_by(affected_waypoints, & &1.edge_id) |> Map.new()

        affected_bonds
        |> Enum.group_by(& &1.bond.element_edge_id)
        |> Enum.map(fn {edge_id, bonds} ->
          {edge_id, Enum.sort_by(bonds, & &1.bond.kind)}
        end)
        |> Enum.reduce_while({:ok, []}, fn
          {_edge_id, []}, {:ok, acc} ->
            {:cont, {:ok, acc}}

          {edge_id,
           [
             %{
               bond: bond,
               box: box,
               edge: edge,
               socket: socket,
               socket_schema: socket_schema
             }
           ]},
          {:ok, acc} ->
            %{update: new_positions} =
              RenewexRouting.align_edge_to_socket(
                if(bond.kind == :source,
                  do: %RenewexRouting.Target{
                    box: box,
                    socket: socket,
                    stencil: Map.get(socket_schema, :stencil, nil)
                  },
                  else: %{position_x: edge.source_x, position_y: edge.source_y}
                ),
                if(
                  bond.kind == :target,
                  do: %RenewexRouting.Target{
                    box: box,
                    socket: socket,
                    stencil: Map.get(socket_schema, :stencil, nil)
                  },
                  else: %{position_x: edge.target_x, position_y: edge.target_y}
                ),
                Map.get(waypoint_map, edge_id, [])
              )

            %Edge{id: edge_id}
            |> Edge.change_position(new_positions)
            |> repo.update()
            |> case do
              {:ok, r} -> {:cont, {:ok, [r | acc]}}
              e -> {:halt, {e}}
            end

          {edge_id,
           [
             %{
               box: box_a,
               edge: edge,
               socket: socket_a,
               socket_schema: socket_schema_a,
               bond: %{kind: :source}
             },
             %{
               box: box_b,
               edge: edge,
               socket: socket_b,
               socket_schema: socket_schema_b,
               bond: %{kind: :target}
             }
           ]},
          {:ok, acc} ->
            %{update: new_positions} =
              RenewexRouting.align_edge_to_socket(
                %RenewexRouting.Target{
                  box: box_a,
                  socket: socket_a,
                  stencil: Map.get(socket_schema_a, :stencil, nil)
                },
                %RenewexRouting.Target{
                  box: box_b,
                  socket: socket_b,
                  stencil: Map.get(socket_schema_b, :stencil, nil)
                },
                Map.get(waypoint_map, edge_id, [])
              )

            %Edge{id: edge_id}
            |> Edge.change_position(new_positions)
            |> repo.update()
            |> case do
              {:ok, r} -> {:cont, {:ok, [r | acc]}}
              e -> {:halt, {e}}
            end
        end)
      end
    )
  end
end
