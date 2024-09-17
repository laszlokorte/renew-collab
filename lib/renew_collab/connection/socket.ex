defmodule RenewCollab.Connection.Socket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "socket" do
    field :name, :string
    field :kind, :string
    belongs_to :socket_schema, RenewCollab.Connection.SocketSchema

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(socket, attrs) do
    socket
    |> cast(attrs, [:name, :kind])
    |> validate_required([:name, :kind])
    |> unique_constraint(:element_id)
  end
end
