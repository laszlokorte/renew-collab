defmodule RenewCollab.Symbol.PathStepArc do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path_step_arc" do
    field :angle, :float, default: 0.0
    field :sweep, :boolean, default: false
    field :large, :boolean, default: false
    field :rx_value, :float, default: 0.0
    field :rx_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :width
    field :rx_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :rx_offset_value_static, :float, default: 0.0
    field :rx_offset_dynamic_value, :float, default: 0.0

    field :rx_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :width

    field :ry_value, :float, default: 0.0
    field :ry_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :height
    field :ry_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :ry_offset_value_static, :float, default: 0.0
    field :ry_offset_dynamic_value, :float, default: 0.0

    field :ry_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :height

    belongs_to :path_step, RenewCollab.Symbol.PathStep

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path_step_arc, attrs) do
    path_step_arc
    |> cast(attrs, [
      :angle,
      :sweep,
      :large,
      :rx_value,
      :rx_unit,
      :rx_offset_operation,
      :rx_offset_value_static,
      :rx_offset_dynamic_value,
      :rx_offset_dynamic_unit,
      :ry_value,
      :ry_unit,
      :ry_offset_operation,
      :ry_offset_value_static,
      :ry_offset_dynamic_value,
      :ry_offset_dynamic_unit
    ])
    |> validate_required([
      :angle,
      :sweep,
      :large,
      :rx_value,
      :rx_unit,
      :rx_offset_operation,
      :rx_offset_value_static,
      :rx_offset_dynamic_value,
      :rx_offset_dynamic_unit,
      :ry_value,
      :ry_unit,
      :ry_offset_operation,
      :ry_offset_value_static,
      :ry_offset_dynamic_value,
      :ry_offset_dynamic_unit
    ])
    |> unique_constraint(:path_step)
  end
end
