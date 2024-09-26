defmodule RenewCollab.Connection.Bond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "connection_bond" do
    belongs_to :element_edge, RenewCollab.Element.Edge, foreign_key: :element_edge_id
    belongs_to :socket, RenewCollab.Connection.Socket
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    field :kind, Ecto.Enum, values: [:source, :target], null: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_bond, attrs) do
    element_connection_bond
    |> cast(attrs, [:element_edge_id, :socket_id, :layer_id, :kind])
    |> validate_required([:socket_id, :layer_id, :kind])
    |> unique_constraint([:element_edge_id, :kind])
  end
end
