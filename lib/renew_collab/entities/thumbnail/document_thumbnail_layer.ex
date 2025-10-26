defmodule RenewCollab.Thumbnail.DocumentThumbnailLayer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "document_thumbnail_layer" do
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    belongs_to :document, RenewCollab.Document.Document
  end

  @doc false
  def changeset(syntax_type, attrs) do
    syntax_type
    |> cast(attrs, [:layer_id, :document_id])
    |> validate_required([:document_id, :layer_id])
    |> unique_constraint(:document_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Thumbnail.DocumentThumbnailLayer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :thumbnail
    def schema(), do: DocumentThumbnailLayer

    def query(document_id) do
      import Ecto.Query, warn: false

      from(t in DocumentThumbnailLayer,
        where: t.document_id == ^document_id,
        select: %{
          id: t.id,
          layer_id: t.layer_id,
          document_id: t.document_id
        }
      )
    end
  end
end
