defmodule RenewCollab.SymbolFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RenewCollab.Symbol` context.
  """

  @doc """
  Generate a unique shape name.
  """
  def unique_shape_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a shape.
  """
  def shape_fixture(attrs \\ %{}) do
    {:ok, shape} =
      attrs
      |> Enum.into(%{
        name: unique_shape_name()
      })
      |> RenewCollab.Symbol.create_shape()

    shape
  end

  @doc """
  Generate a path.
  """
  def path_fixture(attrs \\ %{}) do
    {:ok, path} =
      attrs
      |> Enum.into(%{
        fill_color: "some fill_color",
        sort: 42,
        stroke_color: "some stroke_color"
      })
      |> RenewCollab.Symbol.create_path()

    path
  end

  @doc """
  Generate a path_segment.
  """
  def path_segment_fixture(attrs \\ %{}) do
    {:ok, path_segment} =
      attrs
      |> Enum.into(%{
        relative: true,
        sort: 42,
        x_offset_dynamic_unit: :width,
        x_offset_dynamic_value: 120.5,
        x_offset_operation: :sum,
        x_offset_value_static: 120.5,
        x_unit: :width,
        x_value: 120.5,
        y_offset_dynamic_unit: :width,
        y_offset_dynamic_value: 120.5,
        y_offset_operation: :sum,
        y_offset_value_static: 120.5,
        y_unit: :width,
        y_value: 120.5
      })
      |> RenewCollab.Symbol.create_path_segment()

    path_segment
  end

  @doc """
  Generate a path_step.
  """
  def path_step_fixture(attrs \\ %{}) do
    {:ok, path_step} =
      attrs
      |> Enum.into(%{
        relative: true,
        sort: 42
      })
      |> RenewCollab.Symbol.create_path_step()

    path_step
  end

  @doc """
  Generate a path_step_vertical.
  """
  def path_step_vertical_fixture(attrs \\ %{}) do
    {:ok, path_step_vertical} =
      attrs
      |> Enum.into(%{
        y_offset_dynamic_unit: :width,
        y_offset_dynamic_value: 120.5,
        y_offset_operation: :sum,
        y_offset_value_static: 120.5,
        y_unit: :width,
        y_value: 120.5
      })
      |> RenewCollab.Symbol.create_path_step_vertical()

    path_step_vertical
  end

  @doc """
  Generate a path_step_horizontal.
  """
  def path_step_horizontal_fixture(attrs \\ %{}) do
    {:ok, path_step_horizontal} =
      attrs
      |> Enum.into(%{
        x_offset_dynamic_unit: :width,
        x_offset_dynamic_value: 120.5,
        x_offset_operation: :sum,
        x_offset_value_static: 120.5,
        x_unit: :width,
        x_value: 120.5
      })
      |> RenewCollab.Symbol.create_path_step_horizontal()

    path_step_horizontal
  end

  @doc """
  Generate a path_step_arc.
  """
  def path_step_arc_fixture(attrs \\ %{}) do
    {:ok, path_step_arc} =
      attrs
      |> Enum.into(%{
        angle: 120.5,
        large: true,
        rx_offset_dynamic_unit: :width,
        rx_offset_dynamic_value: 120.5,
        rx_offset_operation: :sum,
        rx_offset_value_static: 120.5,
        rx_unit: :width,
        rx_value: 120.5,
        ry_offset_dynamic_unit: :width,
        ry_offset_dynamic_value: 120.5,
        ry_offset_operation: :sum,
        ry_offset_value_static: 120.5,
        ry_unit: :width,
        ry_value: 120.5,
        sweep: true
      })
      |> RenewCollab.Symbol.create_path_step_arc()

    path_step_arc
  end
end
