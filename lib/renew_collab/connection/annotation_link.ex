defmodule RenewCollab.Connection.AnnotationLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "annotation_link" do
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    belongs_to :text, RenewCollab.Element.Text

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(annotation_link, attrs) do
    annotation_link
    |> cast(attrs, [:layer_id, :text_id])
    |> validate_required([:layer_id, :text_id])
    |> unique_constraint(:text_id)
  end
end
