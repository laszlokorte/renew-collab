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

  defp build_step(box, startPos, {x, y}, step) do
    {"", {x, y}}
  end

  defp build_coord(box, axis, relative, pos) do
    0
  end
end
