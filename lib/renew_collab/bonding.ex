defmodule RenewCollab.Bonding do
  import Ecto.Query, warn: false
  alias RenewCollab.Repo
  alias RenewCollab.Symbols
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

          with %{position_x: x, position_y: y} <- align_to_socket(box, socket, relevant_waypoint) do
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
              align_to_socket(box_b, socket_b, %{
                position_x: edge.source_x,
                position_y: edge.source_y
              })
            )

          last_waypoint_a =
            List.last(
              waypoints,
              align_to_socket(box_b, socket_b, %{
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
              align_to_socket(box_a, socket_a, %{
                position_x: edge.source_x,
                position_y: edge.source_y
              })
            )

          last_waypoint_b =
            List.last(
              waypoints,
              align_to_socket(box_a, socket_a, %{
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
                 align_to_socket(box_a, socket_a, relevant_waypoint_a, socket_schema_a),
               %{position_x: xb, position_y: yb} <-
                 align_to_socket(box_b, socket_b, relevant_waypoint_b, socket_schema_b) do
            Edge.change_position(%Edge{id: edge_id}, %{
              :"#{bond_a.kind}_x" => xa,
              :"#{bond_a.kind}_y" => ya,
              :"#{bond_b.kind}_x" => xb,
              :"#{bond_b.kind}_y" => yb
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

  defp align_to_socket(box, socket, relevant_waypoint, socket_schema \\ nil) do
    box_center_x = box.position_x + box.width / 2
    box_center_y = box.position_y + box.height / 2
    target_x = Symbols.build_coord(box, :x, false, Symbols.unify_coord(:x, socket))
    target_y = Symbols.build_coord(box, :y, false, Symbols.unify_coord(:y, socket))

    dir_x = relevant_waypoint.position_x - target_x
    dir_y = relevant_waypoint.position_y - target_y
    dir_len = hypot(dir_x, dir_y)
    dir_x_norm = if(dir_len > 0, do: dir_x / dir_len, else: 0)
    dir_y_norm = if(dir_len > 0, do: dir_y / dir_len, else: 0)

    dist =
      if socket_schema &&
           sdf(
             socket_schema.stencil,
             box,
             {relevant_waypoint.position_x, relevant_waypoint.position_y}
           ) > 0 do
        Stream.unfold({target_x, target_y}, fn
          {x, y} ->
            d = sdf(socket_schema.stencil, box, {x, y})

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
        |> Stream.take(10)
        |> Enum.sum()
      else
        0
      end

    %{
      position_x: target_x - dir_x_norm * dist,
      position_y: target_y - dir_y_norm * dist
    }
  end

  defp sdf(:rect, box, {x, y}) do
    box_center_x = box.position_x + box.width / 2
    box_center_y = box.position_y + box.height / 2
    rel_x = x - box_center_x
    rel_y = y - box_center_y
    dist_x = abs(rel_x) - box.width / 2
    dist_y = abs(rel_y) - box.height / 2

    outside_distance = hypot(max(dist_x, 0), max(dist_y, 0))
    inside_distance = min(max(dist_x, dist_y), 0)

    outside_distance + inside_distance
  end

  @epsilon 0.00001
  defp sdf(:ellipse, box, {x, y}) do
    rx = box.width / 2.0
    ry = box.height / 2.0
    box_center_x = box.position_x + rx
    box_center_y = box.position_y + ry

    rel_x = x - box_center_x
    rel_y = y - box_center_y

    k1_x = rel_x / rx
    k1_y = rel_y / ry

    k1 = max(hypot(rel_x / rx, rel_y / ry), @epsilon)
    k2 = max(hypot(rel_x / (rx * rx), rel_y / (ry * ry)), @epsilon)

    k1 * (k1 - 1.0) / k2
  end

  defp sdf(d, box, {x, y}) do
    0
  end

  defp hypot(x, y) do
    :math.sqrt(x * x + y * y)
  end
end
