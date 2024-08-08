defmodule RenewCollab.Renew.ElementConnectionSourceBond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_source_bond" do

    belongs_to :element_connection, RenewCollab.Renew.ElementConnection
    belongs_to :source_socket, RenewCollab.Renew.ElementSocket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_source_bond, attrs) do
    element_connection_source_bond
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:element_connection_id)
  end
end
