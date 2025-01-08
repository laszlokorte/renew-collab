defmodule RenewCollab.ViewBox do
  alias RenewCollab.Document.Document
  alias RenewCollab.ViewBox

  defstruct [:x, :y, :width, :height]

  def new(x, y, width, height) do
    %ViewBox{x: x, y: y, width: width, height: height}
  end

  def calculate(%Document{} = document, padding \\ 100) do
    case document.layers do
      %Ecto.Association.NotLoaded{} ->
        %ViewBox{x: -padding, y: -padding, width: 2 * padding, height: 2 * padding}

      layers ->
        edge_points =
          layers
          |> Enum.map(& &1.edge)
          |> Enum.flat_map(fn
            nil ->
              []

            e ->
              [
                {e.source_x, e.source_y},
                {e.target_x, e.target_y}
                | e.waypoints |> Enum.map(fn %{position_x: x, position_y: y} -> {x, y} end)
              ]
          end)

        box_points =
          layers
          |> Enum.map(& &1.box)
          |> Enum.flat_map(fn
            nil ->
              []

            b ->
              [
                {b.position_x, b.position_y},
                {b.position_x + b.width, b.position_y},
                {b.position_x + b.width, b.position_y + b.height},
                {b.position_x, b.position_y + b.height}
              ]
          end)

        text_points =
          layers
          |> Enum.map(& &1.text)
          |> Enum.flat_map(fn
            nil ->
              []

            %{size_hint: %{}} = t ->
              [
                {t.position_x, t.position_y},
                {hint.position_x + hint.width, hint.position_y + hint.height},
                {hint.position_x, hint.position_y}
              ]

            t = %{} ->
              [{t.position_x, t.position_y}]
          end)

        points = Enum.concat([text_points, edge_points, box_points])

        {{min_viewbox_x, _}, {max_viewbox_x, _}} =
          points |> Enum.min_max_by(&elem(&1, 0), fn -> {{0, 0}, {0, 0}} end)

        {{_, min_viewbox_y}, {_, max_viewbox_y}} =
          points |> Enum.min_max_by(&elem(&1, 1), fn -> {{0, 0}, {0, 0}} end)

        %ViewBox{
          x: min_viewbox_x - padding,
          y: min_viewbox_y - padding,
          width: max_viewbox_x - min_viewbox_x + 2 * padding,
          height: max_viewbox_y - min_viewbox_y + 2 * padding
        }
    end
  end

  def center(%ViewBox{x: x, y: y, width: width, height: height}) do
    {x + width / 2, y + height / 2}
  end

  def into_string(%ViewBox{x: x, y: y, width: width, height: height}) do
    "#{x} #{y} #{width} #{height}"
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()
end
