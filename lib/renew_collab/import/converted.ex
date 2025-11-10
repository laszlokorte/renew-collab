defmodule RenewCollab.Import.Converted do
  defstruct [
    :name,
    :kind,
    :layers,
    :hierarchy,
    :hyperlinks,
    :bonds,
    :thumbnail
  ]

  def new(
        name,
        kind,
        layers,
        hierarchy,
        hyperlinks,
        bonds
      ) do
    %RenewCollab.Import.Converted{
      name: name,
      kind: kind,
      layers: layers,
      hierarchy: hierarchy,
      hyperlinks: hyperlinks,
      bonds: bonds
    }
  end

  def shift_positions(doc, dx, dy) do
    Map.update(
      doc,
      :layers,
      [],
      &Enum.map(&1, fn l -> shift_layer(l, dx, dy) end)
    )
  end

  def shift_layer(layer, dx, dy) do
    layer
    |> Map.update("box", nil, fn
      nil ->
        nil

      box = %{"position_x" => old_x, "position_y" => old_y} ->
        %{box | "position_x" => old_x + dx, "position_y" => old_y + dy}
    end)
    |> Map.update("text", nil, fn
      nil ->
        nil

      text = %{"position_x" => old_x, "position_y" => old_y} ->
        %{text | "position_x" => old_x + dx, "position_y" => old_y + dy}
    end)
    |> Map.update(
      "edge",
      nil,
      fn
        nil ->
          nil

        edge = %{
          "source_x" => old_sx,
          "source_y" => old_sy,
          "target_x" => old_tx,
          "target_y" => old_ty,
          "waypoints" => waypoints
        } ->
          %{
            edge
            | "source_x" => old_sx + dx,
              "source_y" => old_sy + dy,
              "target_x" => old_tx + dx,
              "target_y" => old_ty + dy,
              "waypoints" =>
                waypoints
                |> Enum.map(fn
                  wp = %{"position_x" => px, "position_y" => py} ->
                    %{wp | "position_x" => px + dx, "position_y" => py + dy}
                end)
          }
      end
    )
  end
end
