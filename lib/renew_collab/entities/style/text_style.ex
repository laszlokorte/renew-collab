defmodule RenewCollab.Style.TextStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text_style" do
    field :italic, :boolean, default: false
    field :underline, :boolean, default: false
    field :rich, :boolean, default: false
    field :blank_lines, :boolean, default: false
    field :alignment, Ecto.Enum, values: [:left, :center, :right], default: :left
    field :font_size, :float, default: 12.0
    field :font_family, :string, default: "sans-serif"
    field :bold, :boolean, default: false
    field :text_color, :string, default: "black"
    belongs_to :text, RenewCollab.Element.Text

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text_style, attrs) do
    element_text_style
    |> cast(attrs, [
      :alignment,
      :font_size,
      :font_family,
      :bold,
      :italic,
      :underline,
      :rich,
      :text_color,
      :blank_lines
    ])
    |> validate_required([
      :alignment,
      :font_size,
      :font_family,
      :bold,
      :italic,
      :underline,
      :rich,
      :text_color,
      :blank_lines
    ])
    |> unique_constraint(:element_text_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Style.TextStyle
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :text_styles
    def schema(), do: TextStyle

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: t in assoc(l, :text),
        join: s in assoc(t, :style),
        select: %{
          id: s.id,
          italic: s.italic,
          underline: s.underline,
          rich: s.rich,
          blank_lines: s.blank_lines,
          alignment: s.alignment,
          font_size: s.font_size,
          font_family: s.font_family,
          bold: s.bold,
          text_color: s.text_color,
          text_id: s.text_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
    end
  end
end
