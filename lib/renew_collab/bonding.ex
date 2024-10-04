defmodule RenewCollab.Bonding do
  import Ecto.Query, warn: false
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge

  def reposition_multi() do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{affected_bond_ids: affected_bond_ids} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          left_join: box in assoc(l, :box),
          left_join: text in assoc(l, :text),
          left_join: size_hint in assoc(text, :size_hint),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.id in ^affected_bond_ids,
          select: %{
            bond: bond,
            box: box,
            size_hint: size_hint,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
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
          {edge_id,
           bonds
           |> Enum.map(&Map.put(&1, :bounds, &1.box || &1.size_hint))
           |> Enum.filter(& &1.bounds)
           |> Enum.sort_by(& &1.bond.kind)}
        end)
        |> Enum.reduce_while({:ok, []}, fn
          {_edge_id, []}, {:ok, acc} ->
            {:cont, {:ok, acc}}

          {edge_id,
           [
             %{
               bond: bond,
               bounds: bounds,
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
                    box: bounds,
                    socket: socket,
                    stencil: Map.get(socket_schema, :stencil, nil)
                  },
                  else: %{position_x: edge.source_x, position_y: edge.source_y}
                ),
                if(
                  bond.kind == :target,
                  do: %RenewexRouting.Target{
                    box: bounds,
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
               bounds: bounds_a,
               edge: edge,
               socket: socket_a,
               socket_schema: socket_schema_a,
               bond: %{kind: :source}
             },
             %{
               bounds: bounds_b,
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
                  box: bounds_a,
                  socket: socket_a,
                  stencil: Map.get(socket_schema_a, :stencil, nil)
                },
                %RenewexRouting.Target{
                  box: bounds_b,
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
