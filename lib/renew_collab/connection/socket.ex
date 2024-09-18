defmodule RenewCollab.Connection.Socket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "socket" do
    field :name, :string
    belongs_to :socket_schema, RenewCollab.Connection.SocketSchema

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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(socket, attrs) do
    socket
    |> cast(attrs, [
      :socket_schema_id,
      :name,
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
    |> validate_required([:name])
    |> unique_constraint([:socket_schema_id, :name])
  end
end
