defmodule RenewCollab.Symbol do
  @moduledoc """
  The Symbol context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Symbol.Path
  alias RenewCollab.Symbol.PathSegment
  alias RenewCollab.Symbol.PathStep
  alias RenewCollab.Symbol.PathStepHorizontal
  alias RenewCollab.Symbol.PathStepVertical
  alias RenewCollab.Symbol.PathStepArc

  @doc """
  Returns the list of shape.

  ## Examples

      iex> list_shape()
      [%Shape{}, ...]

  """
  def list_shapes do
    Repo.all(Shape)
    |> Repo.preload(
      paths:
        from(p in Path,
          order_by: [asc: :sort],
          preload: [
            segments:
              ^from(s in PathSegment,
                order_by: [asc: :sort],
                preload: [
                  steps:
                    ^from(s in PathStep,
                      order_by: [asc: :sort],
                      preload: [
                        :horizontal,
                        :vertical,
                        :arc
                      ]
                    )
                ]
              )
          ]
        )
    )
  end

  def ids_by_name do
    from(p in Shape, select: {p.name, p.id})
    |> Repo.all()
    |> Map.new()
  end

  def reset do
    Repo.delete_all(Shape)

    RenewCollab.Symbol.PredefinedSymbols.all()
    |> Enum.reduce(Ecto.Multi.new(), fn shape, multi ->
      multi |> Ecto.Multi.insert(Map.get(shape, "name"), %Shape{} |> Shape.changeset(shape))
    end)
    |> Repo.transaction()
  end

  def build_symbol_path(
        %RenewCollab.Element.Box{
          position_x: x,
          position_y: y,
          width: width,
          height: height
        } = box,
        %RenewCollab.Symbol.Path{
          segments: segments
        }
      ) do
    segments
    |> Enum.map(fn segment ->
      start =
        {start_x, start_y} = {
          build_coord(box, :x, segment.relative, extract_coord(:x, segment)),
          build_coord(box, :y, segment.relative, extract_coord(:y, segment))
        }

      {path_string, _end_pos} =
        segment.steps
        |> Enum.reduce(
          {
            "#{if(segment.relative, do: "m", else: "M")} #{start_x} #{start_x}",
            start
          },
          fn step, {current_string, current_pos} ->
            {next_string, next_pos} =
              build_step(
                box,
                start,
                current_pos,
                step
              )

            {[current_string, next_string], next_pos}
          end
        )

      path_string
    end)
    |> Enum.join(" ")

    "M #{x} #{y} h #{width} v #{height} h #{-width} v #{-height} z"
  end

  defp extract_coord(:x, obj) do
    %{
      value: obj.x_value,
      unit: obj.x_unit,
      offset: %{
        operation: obj.x_offset_operation,
        value_static: obj.x_offset_value_static,
        dynamic_value: obj.x_offset_dynamic_value,
        dynamic_unit: obj.x_offset_dynamic_unit
      }
    }
  end

  defp extract_coord(:y, obj) do
    %{
      value: obj.y_value,
      unit: obj.y_unit,
      offset: %{
        operation: obj.y_offset_operation,
        value_static: obj.y_offset_value_static,
        dynamic_value: obj.y_offset_dynamic_value,
        dynamic_unit: obj.y_offset_dynamic_unit
      }
    }
  end

  defp extract_coord(:rx, obj) do
    %{
      value: obj.rx_value,
      unit: obj.rx_unit,
      offset: %{
        operation: obj.rx_offset_operation,
        value_static: obj.rx_offset_value_static,
        dynamic_value: obj.rx_offset_dynamic_value,
        dynamic_unit: obj.rx_offset_dynamic_unit
      }
    }
  end

  defp extract_coord(:ry, obj) do
    %{
      value: obj.ry_value,
      unit: obj.ry_unit,
      offset: %{
        operation: obj.ry_offset_operation,
        value_static: obj.ry_offset_value_static,
        dynamic_value: obj.ry_offset_dynamic_value,
        dynamic_unit: obj.ry_offset_dynamic_unit
      }
    }
  end

  defp build_step(box, start_pos, {current_x, current_y}, step) do
    # const relative = !!step.relative;
    # const vertical = !!step.vertical;
    # const horizontal = !!step.horizontal;
    # const diagonal = vertical && horizontal;
    # const arc = !!step.arc;

    cond do
      step.arc ->
        {"", {current_x, current_y}}

        cond do
          step.vertical != nil and step.horizontal != nil -> {"", {current_x, current_y}}
          step.vertical != nil -> {"", {current_x, current_y}}
          step.horizontal != nil -> {"", {current_x, current_y}}
        end

      step.vertical != nil and step.horizontal != nil ->
        {"", {current_x, current_y}}

      step.vertical != nil ->
        y = build_coord(box, :x, step.relative, extract_coord(:y, step.vertical))
        {"", {current_x, current_y}}

      step.horizontal != nil ->
        x = build_coord(box, :x, step.relative, extract_coord(:x, step.horizontal))
        {"", {current_x, current_y}}

      true ->
        {if(step.relative, do: "z", else: "Z"), start_pos}
    end

    # if (arc) {
    #   const rx = buildCoord(box, "x", true, step.arc.rx);
    #   const ry = buildCoord(box, "y", true, step.arc.ry);
    #   const params =
    #     rx +
    #     "," +
    #     ry +
    #     "," +
    #     (step.arc.angle ? 1 : 0) +
    #     "," +
    #     (step.arc.sweep ? 1 : 0) +
    #     "," +
    #     (step.arc.large ? 1 : 0);

    #   if (diagonal) {
    #     const x = buildCoord(box, "x", step.relative, step.horizontal);
    #     const y = buildCoord(box, "y", step.relative, step.vertical);

    #     return {
    #       string: (relative ? "a" : "A") + params + "," + x + "," + y,
    #       pos: relative
    #         ? { x: currentX + x, y: currentY + y }
    #         : { x, y },
    #     };
    #   } else if (vertical) {
    #     const y = buildCoord(box, "y", step.relative, step.vertical);
    #     return {
    #       string:
    #         (relative ? "a" : "A") +
    #         params +
    #         "," +
    #         (relative ? 0 : currentX) +
    #         "," +
    #         y,
    #       pos: relative
    #         ? { x: currentX, y: currentY + y }
    #         : { x: currentX, y },
    #     };
    #   } else if (horizontal) {
    #     const x = buildCoord(box, "x", step.relative, step.horizontal);
    #     return {
    #       string:
    #         (relative ? "a" : "A") +
    #         params +
    #         "," +
    #         x +
    #         "," +
    #         (relative ? 0 : currentY),
    #       pos: relative
    #         ? { x: currentX + x, y: currentY }
    #         : { x, y: currentY },
    #     };
    #   } else {
    #     return {
    #       string:
    #         (relative ? "a" : "A") +
    #         params +
    #         "," +
    #         (relative ? 0 : currentX) +
    #         "," +
    #         (relative ? 0 : currentY),
    #       pos: relative
    #         ? { x: currentX + x, y: currentY + y }
    #         : { x: currentX, y: currentY },
    #     };
    #   }
    # } else {
    #   if (diagonal) {
    #     const x = buildCoord(box, "x", step.relative, step.horizontal);
    #     const y = buildCoord(box, "y", step.relative, step.vertical);
    #     return {
    #       string: (relative ? "l" : "L") + x + "," + y,
    #       pos: relative
    #         ? { x: currentX + x, y: currentY + y }
    #         : { x, y },
    #     };
    #   } else if (vertical) {
    #     const y = buildCoord(box, "y", step.relative, step.vertical);
    #     return {
    #       string: (relative ? "v" : "V") + y,
    #       pos: relative
    #         ? { x: currentX, y: currentY + y }
    #         : { x: currentX, y },
    #     };
    #   } else if (horizontal) {
    #     const x = buildCoord(box, "x", step.relative, step.horizontal);
    #     return {
    #       string: (relative ? "h" : "H") + x,
    #       pos: relative
    #         ? { x: currentX + x, y: currentY }
    #         : { x, y: currentY },
    #     };
    #   } else {
    #     return {
    #       string: relative ? "z" : "Z",
    #       pos: startPos,
    #     };
    #   }
    # }

    {"", {current_x, current_y}}
  end

  defp build_coord(box, axis, relative, coord) do
    # const units = {
    #   maxsize: Math.max(box.width, box.height),
    #   minsize: Math.min(box.width, box.height),
    #   width: box.width,
    #   height: box.height,
    # };

    # const ops = {
    #   max: (a, b) => Math.max(a, b),
    #   min: (a, b) => Math.min(a, b),
    #   sum: (a, b) => a + b,
    # };

    origin = box_axis(axis, box)
    base = coord.value * unit(coord.unit, box)

    offset =
      op(
        coord.offset.operation,
        coord.offset.value_static,
        unit(coord.offset.dynamic_unit, box) * coord.offset.dynamic_value
      )

    if(relative, do: base, else: base + origin) + offset
    # return (relative ? base : base + origin) + offset;
  end

  def box_axis(:x, box), do: box.position_x
  def box_axis(:y, box), do: box.position_y

  def unit(:maxsize, box), do: max(box.width, box.height)
  def unit(:minsize, box), do: min(box.width, box.height)
  def unit(:width, box), do: box.width
  def unit(:height, box), do: box.height

  def op(:max, a, b), do: max(a, b)
  def op(:min, a, b), do: min(a, b)
  def op(:sum, a, b), do: a + b
end
