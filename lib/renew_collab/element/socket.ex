defmodule RenewCollab.Element.Socket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_socket" do
    field :name, :string
    field :kind, :string
    belongs_to :layer, RenewCollab.Hierarchy.Layer

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
