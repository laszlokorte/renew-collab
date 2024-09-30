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

  defmodule Snapshotter do
    alias RenewCollab.Hierarchy.LayerParenthood
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :layer_parenthoods
    def schema(), do: LayerParenthood

    def query(document_id) do
      import Ecto.Query, warn: false

      from(p in LayerParenthood,
        where: p.document_id == ^document_id,
        select: %{
          id: p.id,
          depth: p.depth,
          document_id: p.document_id,
          ancestor_id: p.ancestor_id,
          descendant_id: p.descendant_id
        }
      )
    end
  end
end
