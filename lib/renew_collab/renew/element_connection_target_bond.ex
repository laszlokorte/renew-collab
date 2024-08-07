defmodule RenewCollab.Renew.ElementConnectionTargetBond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_target_bond" do

    field :element_connection_id, :binary_id
    field :target_socket_id, :binary_id

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
