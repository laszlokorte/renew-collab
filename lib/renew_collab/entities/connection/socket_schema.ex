defmodule RenewCollab.Connection.SocketSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "socket_schema" do
    field :name, :string
    field :stencil, Ecto.Enum, values: [:rect, :ellipse], null: false
    has_many :sockets, RenewCollab.Connection.Socket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(socket_schema, attrs) do
    socket_schema
    |> cast(attrs, [:name, :stencil])
    |> cast_assoc(:sockets)
    |> unique_constraint([:name])
    |> validate_required([:name])
  end
end
