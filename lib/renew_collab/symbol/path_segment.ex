defmodule RenewCollab.Symbol.PathSegment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path_segment" do
    field :sort, :integer
    field :relative, :boolean, default: false
    field :x_value, :float, default: 0.0
    field :x_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :width
    field :x_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :x_offset_value_static, :float, default: 0.0
    field :x_offset_dynamic_value, :float, default: 0.0

    field :x_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :width

    field :y_value, :float, default: 0.0
    field :y_unit, Ecto.Enum, values: [:width, :height, :minsize, :maxsize], default: :height
    field :y_offset_operation, Ecto.Enum, values: [:sum, :min, :max], default: :sum
    field :y_offset_value_static, :float, default: 0.0
    field :y_offset_dynamic_value, :float, default: 0.0

    field :y_offset_dynamic_unit, Ecto.Enum,
      values: [:width, :height, :minsize, :maxsize],
      default: :height

    belongs_to :path, RenewCollab.Symbol.Path
    has_many :steps, RenewCollab.Symbol.PathStep, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path_segment, attrs) do
    path_segment
    |> cast(attrs, [
      :sort,
      :relative,
      :x_value,
      :x_unit,
      :x_offset_operation,
      :x_offset_value_static,
      :x_offset_dynamic_value,
      :x_offset_dynamic_unit,
      :y_value,
      :y_unit,
      :y_offset_operation,
      :y_offset_value_static,
      :y_offset_dynamic_value,
      :y_offset_dynamic_unit
    ])
    |> cast_assoc(:steps)
    |> validate_required([
      :sort,
      :relative,
      :x_value,
      :x_unit,
      :x_offset_operation,
      :x_offset_value_static,
      :x_offset_dynamic_value,
      :x_offset_dynamic_unit,
      :y_value,
      :y_unit,
      :y_offset_operation,
      :y_offset_value_static,
      :y_offset_dynamic_value,
      :y_offset_dynamic_unit
    ])
  end
end
