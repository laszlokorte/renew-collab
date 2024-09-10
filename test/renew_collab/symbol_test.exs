defmodule RenewCollab.SymbolTest do
  use RenewCollab.DataCase

  alias RenewCollab.Symbol

  describe "shape" do
    alias RenewCollab.Symbol.Shape

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{name: nil}

    test "list_shape/0 returns all shape" do
      shape = shape_fixture()
      assert Symbol.list_shape() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Symbol.get_shape!(shape.id) == shape
    end

    test "create_shape/1 with valid data creates a shape" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Shape{} = shape} = Symbol.create_shape(valid_attrs)
      assert shape.name == "some name"
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_shape(@invalid_attrs)
    end

    test "update_shape/2 with valid data updates the shape" do
      shape = shape_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Shape{} = shape} = Symbol.update_shape(shape, update_attrs)
      assert shape.name == "some updated name"
    end

    test "update_shape/2 with invalid data returns error changeset" do
      shape = shape_fixture()
      assert {:error, %Ecto.Changeset{}} = Symbol.update_shape(shape, @invalid_attrs)
      assert shape == Symbol.get_shape!(shape.id)
    end

    test "delete_shape/1 deletes the shape" do
      shape = shape_fixture()
      assert {:ok, %Shape{}} = Symbol.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Symbol.get_shape!(shape.id) end
    end

    test "change_shape/1 returns a shape changeset" do
      shape = shape_fixture()
      assert %Ecto.Changeset{} = Symbol.change_shape(shape)
    end
  end

  describe "shape_path" do
    alias RenewCollab.Symbol.Path

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{sort: nil, fill_color: nil, stroke_color: nil}

    test "list_shape_path/0 returns all shape_path" do
      path = path_fixture()
      assert Symbol.list_shape_path() == [path]
    end

    test "get_path!/1 returns the path with given id" do
      path = path_fixture()
      assert Symbol.get_path!(path.id) == path
    end

    test "create_path/1 with valid data creates a path" do
      valid_attrs = %{sort: 42, fill_color: "some fill_color", stroke_color: "some stroke_color"}

      assert {:ok, %Path{} = path} = Symbol.create_path(valid_attrs)
      assert path.sort == 42
      assert path.fill_color == "some fill_color"
      assert path.stroke_color == "some stroke_color"
    end

    test "create_path/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path(@invalid_attrs)
    end

    test "update_path/2 with valid data updates the path" do
      path = path_fixture()

      update_attrs = %{
        sort: 43,
        fill_color: "some updated fill_color",
        stroke_color: "some updated stroke_color"
      }

      assert {:ok, %Path{} = path} = Symbol.update_path(path, update_attrs)
      assert path.sort == 43
      assert path.fill_color == "some updated fill_color"
      assert path.stroke_color == "some updated stroke_color"
    end

    test "update_path/2 with invalid data returns error changeset" do
      path = path_fixture()
      assert {:error, %Ecto.Changeset{}} = Symbol.update_path(path, @invalid_attrs)
      assert path == Symbol.get_path!(path.id)
    end

    test "delete_path/1 deletes the path" do
      path = path_fixture()
      assert {:ok, %Path{}} = Symbol.delete_path(path)
      assert_raise Ecto.NoResultsError, fn -> Symbol.get_path!(path.id) end
    end

    test "change_path/1 returns a path changeset" do
      path = path_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path(path)
    end
  end

  describe "shape_path_segment" do
    alias RenewCollab.Symbol.PathSegment

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{
      sort: nil,
      relative: nil,
      x_value: nil,
      x_unit: nil,
      x_offset_operation: nil,
      x_offset_value_static: nil,
      x_offset_dynamic_value: nil,
      x_offset_dynamic_unit: nil,
      y_value: nil,
      y_unit: nil,
      y_offset_operation: nil,
      y_offset_value_static: nil,
      y_offset_dynamic_value: nil,
      y_offset_dynamic_unit: nil
    }

    test "list_shape_path_segment/0 returns all shape_path_segment" do
      path_segment = path_segment_fixture()
      assert Symbol.list_shape_path_segment() == [path_segment]
    end

    test "get_path_segment!/1 returns the path_segment with given id" do
      path_segment = path_segment_fixture()
      assert Symbol.get_path_segment!(path_segment.id) == path_segment
    end

    test "create_path_segment/1 with valid data creates a path_segment" do
      valid_attrs = %{
        sort: 42,
        relative: true,
        x_value: 120.5,
        x_unit: :width,
        x_offset_operation: :sum,
        x_offset_value_static: 120.5,
        x_offset_dynamic_value: 120.5,
        x_offset_dynamic_unit: :width,
        y_value: 120.5,
        y_unit: :width,
        y_offset_operation: :sum,
        y_offset_value_static: 120.5,
        y_offset_dynamic_value: 120.5,
        y_offset_dynamic_unit: :width
      }

      assert {:ok, %PathSegment{} = path_segment} = Symbol.create_path_segment(valid_attrs)
      assert path_segment.sort == 42
      assert path_segment.relative == true
      assert path_segment.x_value == 120.5
      assert path_segment.x_unit == :width
      assert path_segment.x_offset_operation == :sum
      assert path_segment.x_offset_value_static == 120.5
      assert path_segment.x_offset_dynamic_value == 120.5
      assert path_segment.x_offset_dynamic_unit == :width
      assert path_segment.y_value == 120.5
      assert path_segment.y_unit == :width
      assert path_segment.y_offset_operation == :sum
      assert path_segment.y_offset_value_static == 120.5
      assert path_segment.y_offset_dynamic_value == 120.5
      assert path_segment.y_offset_dynamic_unit == :width
    end

    test "create_path_segment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path_segment(@invalid_attrs)
    end

    test "update_path_segment/2 with valid data updates the path_segment" do
      path_segment = path_segment_fixture()

      update_attrs = %{
        sort: 43,
        relative: false,
        x_value: 456.7,
        x_unit: :height,
        x_offset_operation: :min,
        x_offset_value_static: 456.7,
        x_offset_dynamic_value: 456.7,
        x_offset_dynamic_unit: :height,
        y_value: 456.7,
        y_unit: :height,
        y_offset_operation: :min,
        y_offset_value_static: 456.7,
        y_offset_dynamic_value: 456.7,
        y_offset_dynamic_unit: :height
      }

      assert {:ok, %PathSegment{} = path_segment} =
               Symbol.update_path_segment(path_segment, update_attrs)

      assert path_segment.sort == 43
      assert path_segment.relative == false
      assert path_segment.x_value == 456.7
      assert path_segment.x_unit == :height
      assert path_segment.x_offset_operation == :min
      assert path_segment.x_offset_value_static == 456.7
      assert path_segment.x_offset_dynamic_value == 456.7
      assert path_segment.x_offset_dynamic_unit == :height
      assert path_segment.y_value == 456.7
      assert path_segment.y_unit == :height
      assert path_segment.y_offset_operation == :min
      assert path_segment.y_offset_value_static == 456.7
      assert path_segment.y_offset_dynamic_value == 456.7
      assert path_segment.y_offset_dynamic_unit == :height
    end

    test "update_path_segment/2 with invalid data returns error changeset" do
      path_segment = path_segment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Symbol.update_path_segment(path_segment, @invalid_attrs)

      assert path_segment == Symbol.get_path_segment!(path_segment.id)
    end

    test "delete_path_segment/1 deletes the path_segment" do
      path_segment = path_segment_fixture()
      assert {:ok, %PathSegment{}} = Symbol.delete_path_segment(path_segment)
      assert_raise Ecto.NoResultsError, fn -> Symbol.get_path_segment!(path_segment.id) end
    end

    test "change_path_segment/1 returns a path_segment changeset" do
      path_segment = path_segment_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path_segment(path_segment)
    end
  end

  describe "shape_path_step" do
    alias RenewCollab.Symbol.PathStep

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{sort: nil, relative: nil}

    test "list_shape_path_step/0 returns all shape_path_step" do
      path_step = path_step_fixture()
      assert Symbol.list_shape_path_step() == [path_step]
    end

    test "get_path_step!/1 returns the path_step with given id" do
      path_step = path_step_fixture()
      assert Symbol.get_path_step!(path_step.id) == path_step
    end

    test "create_path_step/1 with valid data creates a path_step" do
      valid_attrs = %{sort: 42, relative: true}

      assert {:ok, %PathStep{} = path_step} = Symbol.create_path_step(valid_attrs)
      assert path_step.sort == 42
      assert path_step.relative == true
    end

    test "create_path_step/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path_step(@invalid_attrs)
    end

    test "update_path_step/2 with valid data updates the path_step" do
      path_step = path_step_fixture()
      update_attrs = %{sort: 43, relative: false}

      assert {:ok, %PathStep{} = path_step} = Symbol.update_path_step(path_step, update_attrs)
      assert path_step.sort == 43
      assert path_step.relative == false
    end

    test "update_path_step/2 with invalid data returns error changeset" do
      path_step = path_step_fixture()
      assert {:error, %Ecto.Changeset{}} = Symbol.update_path_step(path_step, @invalid_attrs)
      assert path_step == Symbol.get_path_step!(path_step.id)
    end

    test "delete_path_step/1 deletes the path_step" do
      path_step = path_step_fixture()
      assert {:ok, %PathStep{}} = Symbol.delete_path_step(path_step)
      assert_raise Ecto.NoResultsError, fn -> Symbol.get_path_step!(path_step.id) end
    end

    test "change_path_step/1 returns a path_step changeset" do
      path_step = path_step_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path_step(path_step)
    end
  end

  describe "shape_path_step_vertical" do
    alias RenewCollab.Symbol.PathStepVertical

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{
      y_value: nil,
      y_unit: nil,
      y_offset_operation: nil,
      y_offset_value_static: nil,
      y_offset_dynamic_value: nil,
      y_offset_dynamic_unit: nil
    }

    test "list_shape_path_step_vertical/0 returns all shape_path_step_vertical" do
      path_step_vertical = path_step_vertical_fixture()
      assert Symbol.list_shape_path_step_vertical() == [path_step_vertical]
    end

    test "get_path_step_vertical!/1 returns the path_step_vertical with given id" do
      path_step_vertical = path_step_vertical_fixture()
      assert Symbol.get_path_step_vertical!(path_step_vertical.id) == path_step_vertical
    end

    test "create_path_step_vertical/1 with valid data creates a path_step_vertical" do
      valid_attrs = %{
        y_value: 120.5,
        y_unit: :width,
        y_offset_operation: :sum,
        y_offset_value_static: 120.5,
        y_offset_dynamic_value: 120.5,
        y_offset_dynamic_unit: :width
      }

      assert {:ok, %PathStepVertical{} = path_step_vertical} =
               Symbol.create_path_step_vertical(valid_attrs)

      assert path_step_vertical.y_value == 120.5
      assert path_step_vertical.y_unit == :width
      assert path_step_vertical.y_offset_operation == :sum
      assert path_step_vertical.y_offset_value_static == 120.5
      assert path_step_vertical.y_offset_dynamic_value == 120.5
      assert path_step_vertical.y_offset_dynamic_unit == :width
    end

    test "create_path_step_vertical/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path_step_vertical(@invalid_attrs)
    end

    test "update_path_step_vertical/2 with valid data updates the path_step_vertical" do
      path_step_vertical = path_step_vertical_fixture()

      update_attrs = %{
        y_value: 456.7,
        y_unit: :height,
        y_offset_operation: :min,
        y_offset_value_static: 456.7,
        y_offset_dynamic_value: 456.7,
        y_offset_dynamic_unit: :height
      }

      assert {:ok, %PathStepVertical{} = path_step_vertical} =
               Symbol.update_path_step_vertical(path_step_vertical, update_attrs)

      assert path_step_vertical.y_value == 456.7
      assert path_step_vertical.y_unit == :height
      assert path_step_vertical.y_offset_operation == :min
      assert path_step_vertical.y_offset_value_static == 456.7
      assert path_step_vertical.y_offset_dynamic_value == 456.7
      assert path_step_vertical.y_offset_dynamic_unit == :height
    end

    test "update_path_step_vertical/2 with invalid data returns error changeset" do
      path_step_vertical = path_step_vertical_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Symbol.update_path_step_vertical(path_step_vertical, @invalid_attrs)

      assert path_step_vertical == Symbol.get_path_step_vertical!(path_step_vertical.id)
    end

    test "delete_path_step_vertical/1 deletes the path_step_vertical" do
      path_step_vertical = path_step_vertical_fixture()
      assert {:ok, %PathStepVertical{}} = Symbol.delete_path_step_vertical(path_step_vertical)

      assert_raise Ecto.NoResultsError, fn ->
        Symbol.get_path_step_vertical!(path_step_vertical.id)
      end
    end

    test "change_path_step_vertical/1 returns a path_step_vertical changeset" do
      path_step_vertical = path_step_vertical_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path_step_vertical(path_step_vertical)
    end
  end

  describe "shape_path_step_horizontal" do
    alias RenewCollab.Symbol.PathStepHorizontal

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{
      x_value: nil,
      x_unit: nil,
      x_offset_operation: nil,
      x_offset_value_static: nil,
      x_offset_dynamic_value: nil,
      x_offset_dynamic_unit: nil
    }

    test "list_shape_path_step_horizontal/0 returns all shape_path_step_horizontal" do
      path_step_horizontal = path_step_horizontal_fixture()
      assert Symbol.list_shape_path_step_horizontal() == [path_step_horizontal]
    end

    test "get_path_step_horizontal!/1 returns the path_step_horizontal with given id" do
      path_step_horizontal = path_step_horizontal_fixture()
      assert Symbol.get_path_step_horizontal!(path_step_horizontal.id) == path_step_horizontal
    end

    test "create_path_step_horizontal/1 with valid data creates a path_step_horizontal" do
      valid_attrs = %{
        x_value: 120.5,
        x_unit: :width,
        x_offset_operation: :sum,
        x_offset_value_static: 120.5,
        x_offset_dynamic_value: 120.5,
        x_offset_dynamic_unit: :width
      }

      assert {:ok, %PathStepHorizontal{} = path_step_horizontal} =
               Symbol.create_path_step_horizontal(valid_attrs)

      assert path_step_horizontal.x_value == 120.5
      assert path_step_horizontal.x_unit == :width
      assert path_step_horizontal.x_offset_operation == :sum
      assert path_step_horizontal.x_offset_value_static == 120.5
      assert path_step_horizontal.x_offset_dynamic_value == 120.5
      assert path_step_horizontal.x_offset_dynamic_unit == :width
    end

    test "create_path_step_horizontal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path_step_horizontal(@invalid_attrs)
    end

    test "update_path_step_horizontal/2 with valid data updates the path_step_horizontal" do
      path_step_horizontal = path_step_horizontal_fixture()

      update_attrs = %{
        x_value: 456.7,
        x_unit: :height,
        x_offset_operation: :min,
        x_offset_value_static: 456.7,
        x_offset_dynamic_value: 456.7,
        x_offset_dynamic_unit: :height
      }

      assert {:ok, %PathStepHorizontal{} = path_step_horizontal} =
               Symbol.update_path_step_horizontal(path_step_horizontal, update_attrs)

      assert path_step_horizontal.x_value == 456.7
      assert path_step_horizontal.x_unit == :height
      assert path_step_horizontal.x_offset_operation == :min
      assert path_step_horizontal.x_offset_value_static == 456.7
      assert path_step_horizontal.x_offset_dynamic_value == 456.7
      assert path_step_horizontal.x_offset_dynamic_unit == :height
    end

    test "update_path_step_horizontal/2 with invalid data returns error changeset" do
      path_step_horizontal = path_step_horizontal_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Symbol.update_path_step_horizontal(path_step_horizontal, @invalid_attrs)

      assert path_step_horizontal == Symbol.get_path_step_horizontal!(path_step_horizontal.id)
    end

    test "delete_path_step_horizontal/1 deletes the path_step_horizontal" do
      path_step_horizontal = path_step_horizontal_fixture()

      assert {:ok, %PathStepHorizontal{}} =
               Symbol.delete_path_step_horizontal(path_step_horizontal)

      assert_raise Ecto.NoResultsError, fn ->
        Symbol.get_path_step_horizontal!(path_step_horizontal.id)
      end
    end

    test "change_path_step_horizontal/1 returns a path_step_horizontal changeset" do
      path_step_horizontal = path_step_horizontal_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path_step_horizontal(path_step_horizontal)
    end
  end

  describe "shape_path_step_arc" do
    alias RenewCollab.Symbol.PathStepArc

    import RenewCollab.SymbolFixtures

    @invalid_attrs %{
      angle: nil,
      sweep: nil,
      large: nil,
      rx_value: nil,
      rx_unit: nil,
      rx_offset_operation: nil,
      rx_offset_value_static: nil,
      rx_offset_dynamic_value: nil,
      rx_offset_dynamic_unit: nil,
      ry_value: nil,
      ry_unit: nil,
      ry_offset_operation: nil,
      ry_offset_value_static: nil,
      ry_offset_dynamic_value: nil,
      ry_offset_dynamic_unit: nil
    }

    test "list_shape_path_step_arc/0 returns all shape_path_step_arc" do
      path_step_arc = path_step_arc_fixture()
      assert Symbol.list_shape_path_step_arc() == [path_step_arc]
    end

    test "get_path_step_arc!/1 returns the path_step_arc with given id" do
      path_step_arc = path_step_arc_fixture()
      assert Symbol.get_path_step_arc!(path_step_arc.id) == path_step_arc
    end

    test "create_path_step_arc/1 with valid data creates a path_step_arc" do
      valid_attrs = %{
        angle: 120.5,
        sweep: true,
        large: true,
        rx_value: 120.5,
        rx_unit: :width,
        rx_offset_operation: :sum,
        rx_offset_value_static: 120.5,
        rx_offset_dynamic_value: 120.5,
        rx_offset_dynamic_unit: :width,
        ry_value: 120.5,
        ry_unit: :width,
        ry_offset_operation: :sum,
        ry_offset_value_static: 120.5,
        ry_offset_dynamic_value: 120.5,
        ry_offset_dynamic_unit: :width
      }

      assert {:ok, %PathStepArc{} = path_step_arc} = Symbol.create_path_step_arc(valid_attrs)
      assert path_step_arc.angle == 120.5
      assert path_step_arc.sweep == true
      assert path_step_arc.large == true
      assert path_step_arc.rx_value == 120.5
      assert path_step_arc.rx_unit == :width
      assert path_step_arc.rx_offset_operation == :sum
      assert path_step_arc.rx_offset_value_static == 120.5
      assert path_step_arc.rx_offset_dynamic_value == 120.5
      assert path_step_arc.rx_offset_dynamic_unit == :width
      assert path_step_arc.ry_value == 120.5
      assert path_step_arc.ry_unit == :width
      assert path_step_arc.ry_offset_operation == :sum
      assert path_step_arc.ry_offset_value_static == 120.5
      assert path_step_arc.ry_offset_dynamic_value == 120.5
      assert path_step_arc.ry_offset_dynamic_unit == :width
    end

    test "create_path_step_arc/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Symbol.create_path_step_arc(@invalid_attrs)
    end

    test "update_path_step_arc/2 with valid data updates the path_step_arc" do
      path_step_arc = path_step_arc_fixture()

      update_attrs = %{
        angle: 456.7,
        sweep: false,
        large: false,
        rx_value: 456.7,
        rx_unit: :height,
        rx_offset_operation: :min,
        rx_offset_value_static: 456.7,
        rx_offset_dynamic_value: 456.7,
        rx_offset_dynamic_unit: :height,
        ry_value: 456.7,
        ry_unit: :height,
        ry_offset_operation: :min,
        ry_offset_value_static: 456.7,
        ry_offset_dynamic_value: 456.7,
        ry_offset_dynamic_unit: :height
      }

      assert {:ok, %PathStepArc{} = path_step_arc} =
               Symbol.update_path_step_arc(path_step_arc, update_attrs)

      assert path_step_arc.angle == 456.7
      assert path_step_arc.sweep == false
      assert path_step_arc.large == false
      assert path_step_arc.rx_value == 456.7
      assert path_step_arc.rx_unit == :height
      assert path_step_arc.rx_offset_operation == :min
      assert path_step_arc.rx_offset_value_static == 456.7
      assert path_step_arc.rx_offset_dynamic_value == 456.7
      assert path_step_arc.rx_offset_dynamic_unit == :height
      assert path_step_arc.ry_value == 456.7
      assert path_step_arc.ry_unit == :height
      assert path_step_arc.ry_offset_operation == :min
      assert path_step_arc.ry_offset_value_static == 456.7
      assert path_step_arc.ry_offset_dynamic_value == 456.7
      assert path_step_arc.ry_offset_dynamic_unit == :height
    end

    test "update_path_step_arc/2 with invalid data returns error changeset" do
      path_step_arc = path_step_arc_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Symbol.update_path_step_arc(path_step_arc, @invalid_attrs)

      assert path_step_arc == Symbol.get_path_step_arc!(path_step_arc.id)
    end

    test "delete_path_step_arc/1 deletes the path_step_arc" do
      path_step_arc = path_step_arc_fixture()
      assert {:ok, %PathStepArc{}} = Symbol.delete_path_step_arc(path_step_arc)
      assert_raise Ecto.NoResultsError, fn -> Symbol.get_path_step_arc!(path_step_arc.id) end
    end

    test "change_path_step_arc/1 returns a path_step_arc changeset" do
      path_step_arc = path_step_arc_fixture()
      assert %Ecto.Changeset{} = Symbol.change_path_step_arc(path_step_arc)
    end
  end
end
