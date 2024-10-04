defmodule RenewCollab.Style.TextSizeHint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "text_size_hint" do
    belongs_to :text, RenewCollab.Element.Text

    field :position_x, :float
    field :position_y, :float
    field :width, :float
    field :height, :float
  end

  @doc false
  def changeset(text_size_hint, attrs) do
    text_size_hint
    |> cast(attrs, [
      :position_x,
      :position_y,
      :width,
      :height,
      :text_id
    ])
    |> validate_required([
      :position_x,
      :position_y,
      :width,
      :height,
      :text_id
    ])
    |> unique_constraint(:text_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Style.TextSizeHint
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :text_size_hints
    def schema(), do: TextSizeHint

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: t in assoc(l, :text),
        join: h in assoc(t, :size_hint),
        select: %{
          id: h.id,
          text_id: h.text_id,
          position_x: h.position_x,
          position_y: h.position_y,
          width: h.width,
          height: h.height
        }
      )
    end
  end
end
