defmodule RenewCollab.Hierarchy.LayerParenthood do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "layer_parenthood" do
    field :depth, :integer
    field :document_id, :binary_id
    field :ancestor_id, :binary_id
    field :descendant_id, :binary_id
  end

  @doc false
  def changeset(layer_parenthood, attrs) do
    layer_parenthood
    |> cast(attrs, [:depth, :ancestor_id, :descendant_id, :document_id])
    |> validate_required([:depth, :ancestor_id, :descendant_id, :document_id])
  end
end
