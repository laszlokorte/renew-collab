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
    Repo.all(Shape, order_by: [asc: :name])
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
        %{
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
          build_coord(box, :x, segment.relative, unify_coord(:x, segment)),
          build_coord(box, :y, segment.relative, unify_coord(:y, segment))
        }

      {path_string, _end_pos} =
        segment.steps
        |> Enum.reduce(
          {
            "#{svg_command(:move, segment.relative)} #{start_x} #{start_y}",
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

      :erlang.iolist_to_binary(path_string)
    end)
    |> Enum.join(" ")
  end

  defp unify_coord(:x, obj) do
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

  defp unify_coord(:y, obj) do
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

  defp unify_coord(:rx, obj) do
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

  defp unify_coord(:ry, obj) do
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

  defp build_step(box, start_pos, {current_x, current_y} = current_pos, step) do
    # const relative = !!step.relative;
    # const vertical = !!step.vertical;
    # const horizontal = !!step.horizontal;
    # const diagonal = vertical && horizontal;
    # const arc = !!step.arc;

    cond do
      step.arc ->
        rx = build_coord(box, :x, true, unify_coord(:rx, step.arc))
        ry = build_coord(box, :y, true, unify_coord(:ry, step.arc))

        angle = step.arc.angle
        large = step.arc.large
        sweep = step.arc.sweep

        {x, y} =
          cond do
            step.vertical != nil and step.horizontal != nil ->
              x = build_coord(box, :x, step.relative, unify_coord(:x, step.horizontal))
              y = build_coord(box, :y, step.relative, unify_coord(:y, step.vertical))

              {x, y}

            step.vertical != nil ->
              x = if(step.relative, do: 0, else: current_x)
              y = build_coord(box, :y, step.relative, unify_coord(:y, step.vertical))

              {x, y}

            step.horizontal != nil ->
              x = build_coord(box, :x, step.relative, unify_coord(:x, step.horizontal))
              y = if(step.relative, do: 0, else: current_y)

              {x, y}

            true ->
              x = if(step.relative, do: 0, else: current_x)
              y = if(step.relative, do: 0, else: current_y)

              {x, y}
          end

        {"#{svg_command(:arc, step.relative)} #{rx} #{ry} #{if(angle, do: 1, else: 0)} #{if(sweep, do: 1, else: 0)} #{if(large, do: 1, else: 0)}  #{x} #{y}",
         svg_move(step.relative, current_pos, {x, y})}

      step.vertical != nil and step.horizontal != nil ->
        x = build_coord(box, :x, step.relative, unify_coord(:x, step.horizontal))
        y = build_coord(box, :y, step.relative, unify_coord(:y, step.vertical))

        {"#{svg_command(:diagonal, step.relative)} #{x} #{y}",
         svg_move(step.relative, current_pos, {x, y})}

      step.vertical != nil ->
        y = build_coord(box, :y, step.relative, unify_coord(:y, step.vertical))

        {"#{svg_command(:vertical, step.relative)} #{y}",
         svg_move(step.relative, current_pos, {nil, y})}

      step.horizontal != nil ->
        x = build_coord(box, :x, step.relative, unify_coord(:x, step.horizontal))

        {"#{svg_command(:horizontal, step.relative)} #{x}",
         svg_move(step.relative, current_pos, {x, nil})}

      true ->
        {svg_command(:close, step.relative), start_pos}
    end
  end

  defp svg_command(:close, true), do: "z"
  defp svg_command(:close, false), do: "Z"
  defp svg_command(:vertical, true), do: "v"
  defp svg_command(:vertical, false), do: "V"
  defp svg_command(:horizontal, true), do: "h"
  defp svg_command(:horizontal, false), do: "H"
  defp svg_command(:diagonal, true), do: "l"
  defp svg_command(:diagonal, false), do: "L"
  defp svg_command(:move, true), do: "m"
  defp svg_command(:move, false), do: "M"
  defp svg_command(:arc, true), do: "a"
  defp svg_command(:arc, false), do: "A"

  defp svg_move(true, {old_x, old_y}, {nil, arg_y}) when not is_nil(arg_y),
    do: {old_x, old_y + arg_y}

  defp svg_move(true, {old_x, old_y}, {arg_x, nil}) when not is_nil(arg_x),
    do: {old_x + arg_x, old_y}

  defp svg_move(true, {old_x, old_y}, {arg_x, arg_y})
       when not is_nil(arg_x) and not is_nil(arg_y),
       do: {old_x + arg_x, old_y + arg_y}

  defp svg_move(false, {old_x, old_y}, {nil, arg_y}) when not is_nil(arg_y), do: {old_x, arg_y}
  defp svg_move(false, {old_x, old_y}, {arg_x, nil}) when not is_nil(arg_x), do: {arg_x, old_y}

  defp svg_move(false, {old_x, old_y}, {arg_x, arg_y})
       when not is_nil(arg_x) and not is_nil(arg_y),
       do: {arg_x, arg_y}

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
  def op(:sum, a, b) when is_float(a) and is_float(b), do: a + b
end
