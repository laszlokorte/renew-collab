defmodule RenewCollab.Symbol.PathStepVertical do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path_step_vertical" do
    field :y_value, :float, default: 0.0
    field :y_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :height
    field :y_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :y_offset_value_static, :float, default: 0.0
    field :y_offset_dynamic_value, :float, default: 0.0

    field :y_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :height

    belongs_to :path_step, RenewCollab.Symbol.PathStep

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path_step_vertical, attrs) do
    path_step_vertical
    |> cast(attrs, [
      :y_value,
      :y_unit,
      :y_offset_operation,
      :y_offset_value_static,
      :y_offset_dynamic_value,
      :y_offset_dynamic_unit
    ])
    |> validate_required([
      :y_value,
      :y_unit,
      :y_offset_operation,
      :y_offset_value_static,
      :y_offset_dynamic_value,
      :y_offset_dynamic_unit
    ])
    |> unique_constraint(:path_step)
  end
end
