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
    |> Ecto.Multi.run(:update_edge_points, fn repo,
                                              %{
                                                affected_bonds: affected_bonds,
                                                affected_waypoints: affected_waypoints
                                              } ->
      waypoint_map = Enum.group_by(affected_waypoints, & &1.edge_id) |> Map.new()

      affected_bonds
      |> Enum.group_by(& &1.bond.element_edge_id)
      |> Enum.reduce_while({:ok, []}, fn
        {edge_id, []}, {:ok, acc} ->
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
          waypoints = Map.get(waypoint_map, bond.element_edge_id, [])

          first_waypoint =
            List.first(waypoints, %{position_x: edge.target_x, position_y: edge.target_y})

          last_waypoint =
            List.last(waypoints, %{position_x: edge.source_x, position_y: edge.source_y})

          relevant_waypoint =
            case bond.kind do
              :source -> first_waypoint
              :target -> last_waypoint
            end

          with %{position_x: x, position_y: y} <-
                 RenewCollab.EdgeRouter.align_to_socket(box, socket, relevant_waypoint) do
            Edge.change_position(%Edge{id: bond.element_edge_id}, %{
              :"#{bond.kind}_x" => x,
              :"#{bond.kind}_y" => y
            })
          end
          |> repo.update()
          |> case do
            {:ok, r} -> {:cont, {:ok, [r | acc]}}
            e -> {:halt, {e}}
          end

        {edge_id,
         [
           %{
             bond: bond_a,
             box: box_a,
             edge: edge,
             socket: socket_a,
             socket_schema: socket_schema_a
           },
           %{
             bond: bond_b,
             box: box_b,
             edge: edge,
             socket: socket_b,
             socket_schema: socket_schema_b
           }
         ]},
        {:ok, acc} ->
          waypoints = Map.get(waypoint_map, edge_id, [])

          first_waypoint_a =
            List.first(
              waypoints,
              RenewCollab.EdgeRouter.align_to_socket(box_b, socket_b, %{
                position_x: edge.source_x,
                position_y: edge.source_y
              })
            )

          last_waypoint_a =
            List.last(
              waypoints,
              RenewCollab.EdgeRouter.align_to_socket(box_b, socket_b, %{
                position_x: edge.target_x,
                position_y: edge.target_y
              })
            )

          relevant_waypoint_a =
            case bond_a.kind do
              :source -> first_waypoint_a
              :target -> last_waypoint_a
            end

          first_waypoint_b =
            List.first(
              waypoints,
              RenewCollab.EdgeRouter.align_to_socket(box_a, socket_a, %{
                position_x: edge.source_x,
                position_y: edge.source_y
              })
            )

          last_waypoint_b =
            List.last(
              waypoints,
              RenewCollab.EdgeRouter.align_to_socket(box_a, socket_a, %{
                position_x: edge.target_x,
                position_y: edge.target_y
              })
            )

          relevant_waypoint_b =
            case bond_b.kind do
              :source -> first_waypoint_b
              :target -> last_waypoint_b
            end

          with %{position_x: xa, position_y: ya} <-
                 RenewCollab.EdgeRouter.align_to_socket(
                   box_a,
                   socket_a,
                   relevant_waypoint_a,
                   socket_schema_a
                 ),
               %{position_x: xb, position_y: yb} <-
                 RenewCollab.EdgeRouter.align_to_socket(
                   box_b,
                   socket_b,
                   relevant_waypoint_b,
                   socket_schema_b
                 ) do
            Edge.change_position(%Edge{id: edge_id}, %{
              :"#{bond_a.kind}_x" => xa,
              :"#{bond_a.kind}_y" => ya,
              :"#{bond_b.kind}_x" => xb,
              :"#{bond_b.kind}_y" => yb
            })
          end
          |> repo.update()
          |> case do
            {:ok, r} -> {:cont, {:ok, [r | acc]}}
            e -> {:halt, {e}}
          end
      end)
    end)
  end
end
