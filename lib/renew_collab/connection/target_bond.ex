defmodule RenewCollab.Connection.TargetBond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_target_bond" do
    belongs_to :edge, RenewCollab.Element.Edge
    belongs_to :target_socket, RenewCollab.Connection.Socket

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
