defmodule RenewCollab.Sdf do
  @supported [:rect, :ellipse]

  def supported_functions(), do: @supported

  def distance(:rect, box, {x, y}) do
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
  def distance(:ellipse, box, {x, y}) do
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

  def distance(d, box, {x, y}) do
    0
  end

  defp hypot(x, y) do
    :math.sqrt(x * x + y * y)
  end
end
