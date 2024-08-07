defmodule RenewCollab.Renew.ElementParenthood do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_parenthood" do
    field :depth, :integer
    field :ancestor_id, :binary_id
    field :descendant_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_parenthood, attrs) do
    element_parenthood
    |> cast(attrs, [:depth])
    |> validate_required([:depth])
  end
end
