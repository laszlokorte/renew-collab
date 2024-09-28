defmodule RenewCollab.Raytracer do
  def nearest(nil, _box, {target_x, target_y}, {_waypoint_x, _waypoint_y}) do
    %{
      position_x: target_x,
      position_y: target_y
    }
  end

  def nearest(stencil, box, {target_x, target_y}, {waypoint_x, waypoint_y}) do
    if RenewCollab.Sdf.distance(
         stencil,
         box,
         {waypoint_x, waypoint_y}
       ) > 0 do
      dir_x = waypoint_x - target_x
      dir_y = waypoint_y - target_y
      dir_len = hypot(dir_x, dir_y)
      dir_x_norm = if(dir_len > 0, do: dir_x / dir_len, else: 0)
      dir_y_norm = if(dir_len > 0, do: dir_y / dir_len, else: 0)

      dist =
        Stream.unfold({target_x, target_y}, fn
          {x, y} ->
            d = RenewCollab.Sdf.distance(stencil, box, {x, y})

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

      %{
        position_x: target_x - dir_x_norm * dist,
        position_y: target_y - dir_y_norm * dist
      }
    else
      %{
        position_x: target_x,
        position_y: target_y
      }
    end
  end

  defp hypot(x, y) do
    :math.sqrt(x * x + y * y)
  end
end
