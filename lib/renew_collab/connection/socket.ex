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
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:socket_schema, :name])
  end
end
