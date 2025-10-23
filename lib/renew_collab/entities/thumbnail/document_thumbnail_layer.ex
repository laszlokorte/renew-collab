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
end
