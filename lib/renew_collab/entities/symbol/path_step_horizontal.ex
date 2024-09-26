defmodule RenewCollab.Symbol.PathStepHorizontal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path_step_horizontal" do
    field :x_value, :float, default: 0.0
    field :x_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :width
    field :x_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :x_offset_value_static, :float, default: 0.0
    field :x_offset_dynamic_value, :float, default: 0.0

    field :x_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :width

    belongs_to :path_step, RenewCollab.Symbol.PathStep

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path_step_horizontal, attrs) do
    path_step_horizontal
    |> cast(attrs, [
      :x_value,
      :x_unit,
      :x_offset_operation,
      :x_offset_value_static,
      :x_offset_dynamic_value,
      :x_offset_dynamic_unit
    ])
    |> validate_required([
      :x_value,
      :x_unit,
      :x_offset_operation,
      :x_offset_value_static,
      :x_offset_dynamic_value,
      :x_offset_dynamic_unit
    ])
    |> unique_constraint(:path_step)
  end
end
