defmodule RenewCollab.Connection.ElementConnectionTargetBond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_target_bond" do

    belongs_to :element_connection, RenewCollab.Connection.ElementConnection
    belongs_to :target_socket, RenewCollab.Connection.ElementSocket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_target_bond, attrs) do
    element_connection_target_bond
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:element_connection_id)
  end
end
