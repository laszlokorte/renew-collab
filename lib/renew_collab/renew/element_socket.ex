defmodule RenewCollab.Renew.ElementSocket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_socket" do
    field :name, :string
    field :kind, :string
    field :element_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_socket, attrs) do
    element_socket
    |> cast(attrs, [:name, :kind])
    |> validate_required([:name, :kind])
    |> unique_constraint(:element_id)
  end
end
