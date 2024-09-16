defmodule RenewCollab.Style.TextStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text_style" do
    field :italic, :boolean, default: false
    field :underline, :boolean, default: false
    field :rich, :boolean, default: false
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
      :text_color
    ])
    |> validate_required([
      :alignment,
      :font_size,
      :font_family,
      :bold,
      :italic,
      :underline,
      :rich,
      :text_color
    ])
    |> unique_constraint(:element_text_id)
  end
end
