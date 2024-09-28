defmodule RenewCollab.EdgeRouter do
  def align_to_socket(box, socket, relevant_waypoint, socket_schema \\ nil) do
    target_x =
      RenewCollab.Symbols.build_coord(box, :x, false, RenewCollab.Symbols.unify_coord(:x, socket))

    target_y =
      RenewCollab.Symbols.build_coord(box, :y, false, RenewCollab.Symbols.unify_coord(:y, socket))

    stencil =
      case socket_schema do
        nil -> nil
        %{stencil: s} -> s
      end

    RenewCollab.Raytracer.nearest(
      stencil,
      box,
      {target_x, target_y},
      {relevant_waypoint.position_x, relevant_waypoint.position_y}
    )
  end
end
