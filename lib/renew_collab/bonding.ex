defmodule RenewCollab.Bonding do
  import Ecto.Query, warn: false
  alias RenewCollab.Repo
  alias RenewCollab.Symbol
  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Interface
  alias RenewCollab.Versioning

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
      |> Enum.reduce_while({:ok, []}, fn %{
                                           bond: bond,
                                           box: box,
                                           edge: edge,
                                           socket: socket
                                         },
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

        with {x, y} <- align_to_socket(box, socket, relevant_waypoint) do
          Edge.change_position(%Edge{id: bond.element_edge_id}, %{
            :"#{bond.kind}_x" => x,
            :"#{bond.kind}_y" => y
          })
        end
        |> Repo.update()
        |> case do
          {:ok, r} -> {:cont, {:ok, [r | acc]}}
          e -> {:halt, {e}}
        end
      end)
    end)
  end

  defp align_to_socket(box, socket, relevant_waypoint) do
    box_center_x = box.position_x + box.width / 2
    box_center_y = box.position_y + box.height / 2
    target_x = Symbol.build_coord(box, :x, false, Symbol.unify_coord(:x, socket))
    target_y = Symbol.build_coord(box, :y, false, Symbol.unify_coord(:y, socket))

    dir_x = relevant_waypoint.position_x - target_x
    dir_y = relevant_waypoint.position_y - target_y
    dir_len = hypot(dir_x, dir_y)
    dir_x_norm = dir_x / dir_len
    dir_y_norm = dir_y / dir_len

    dist =
      Stream.unfold({target_x, target_y}, fn
        {x, y} ->
          d = sdf(:rect, box, {x, y})

          if d < 0 do
            {d,
             {
               x + d * dir_x_norm,
               y + d * dir_y_norm
             }}
          else
            nil
          end
      end)
      |> Stream.take(5)
      |> Enum.sum()

    {
      target_x - dir_x_norm * dist,
      target_y - dir_y_norm * dist
    }
  end

  defp sdf(:rect, box, {x, y}) do
    box_center_x = box.position_x + box.width / 2
    box_center_y = box.position_y + box.height / 2
    rel_x = x - box_center_x
    rel_y = y - box_center_y
    dist_x = abs(rel_x) - box.width / 2 - 1
    dist_y = abs(rel_y) - box.height / 2 - 1

    outside_distance = hypot(max(dist_x, 0), max(dist_y, 0))
    inside_distance = min(max(dist_x, dist_y), 0)

    outside_distance + inside_distance
  end

  defp sdf(_, box, {x, y}) do
    0
  end

  defp hypot(x, y) do
    :math.sqrt(x * x + y * y)
  end
end
