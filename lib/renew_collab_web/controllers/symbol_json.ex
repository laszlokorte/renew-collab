defmodule RenewCollabWeb.SymbolJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{shapes: shapes}) do
    %{
      shapes: Enum.map(shapes, &shape_data/1)
    }
  end

  defp shape_data(shape) do
    %{id: shape.id, name: shape.name, paths: Enum.map(shape.paths, &path_data/1)}
  end

  defp path_data(path) do
    %{
      "fill_color" => path.fill_color,
      "stroke_color" => path.stroke_color,
      "segments" => Enum.map(path.segments, &segment_data/1)
    }
  end

  defp segment_data(segment) do
    %{
      "relative" => segment.relative,
      "x" => %{
        "value" => segment.x_value,
        "unit" => segment.x_unit,
        "offset" => %{
          "operation" => segment.x_offset_operation,
          "value_static" => segment.x_offset_value_static,
          "dynamic_value" => segment.x_offset_dynamic_value,
          "dynamic_unit" => segment.x_offset_dynamic_unit
        }
      },
      "y" => %{
        "value" => segment.y_value,
        "unit" => segment.y_unit,
        "offset" => %{
          "operation" => segment.y_offset_operation,
          "value_static" => segment.y_offset_value_static,
          "dynamic_value" => segment.y_offset_dynamic_value,
          "dynamic_unit" => segment.y_offset_dynamic_unit
        }
      },
      "steps" => Enum.map(segment.steps, &step_data/1)
    }
  end

  defp step_data(step) do
    %{
      "relative" => step.relative,
      "horizontal" => horizontal_data(step.horizontal),
      "vertical" => vertical_data(step.vertical),
      "arc" => arc_data(step.arc)
    }
    |> Enum.filter(fn {_k, v} -> not is_nil(v) end)
    |> Map.new()
  end

  defp horizontal_data(nil) do
    nil
  end

  defp horizontal_data(ortho) do
    %{
      "value" => ortho.x_value,
      "unit" => ortho.x_unit,
      "offset" => %{
        "operation" => ortho.x_offset_operation,
        "value_static" => ortho.x_offset_value_static,
        "dynamic_value" => ortho.x_offset_dynamic_value,
        "dynamic_unit" => ortho.x_offset_dynamic_unit
      }
    }
  end

  defp vertical_data(nil) do
    nil
  end

  defp vertical_data(ortho) do
    %{
      "value" => ortho.y_value,
      "unit" => ortho.y_unit,
      "offset" => %{
        "operation" => ortho.y_offset_operation,
        "value_static" => ortho.y_offset_value_static,
        "dynamic_value" => ortho.y_offset_dynamic_value,
        "dynamic_unit" => ortho.y_offset_dynamic_unit
      }
    }
  end

  defp arc_data(nil) do
    nil
  end

  defp arc_data(arc) do
    %{
      "rx" => %{
        "value" => arc.rx_value,
        "unit" => arc.rx_unit,
        "offset" => %{
          "operation" => arc.rx_offset_operation,
          "value_static" => arc.rx_offset_value_static,
          "dynamic_value" => arc.rx_offset_dynamic_value,
          "dynamic_unit" => arc.rx_offset_dynamic_unit
        }
      },
      "ry" => %{
        "value" => arc.ry_value,
        "unit" => arc.ry_unit,
        "offset" => %{
          "operation" => arc.ry_offset_operation,
          "value_static" => arc.ry_offset_value_static,
          "dynamic_value" => arc.ry_offset_dynamic_value,
          "dynamic_unit" => arc.ry_offset_dynamic_unit
        }
      },
      "large" => arc.large,
      "sweep" => arc.sweep,
      "angle" => arc.angle
    }
  end
end
