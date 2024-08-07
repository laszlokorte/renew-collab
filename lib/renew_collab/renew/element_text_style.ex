defmodule RenewCollab.Renew.ElementTextStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text_style" do
    field :italic, :boolean, default: false
    field :underline, :boolean, default: false
    field :alignment, Ecto.Enum, values: [:left, :center, :right]
    field :font_size, :float
    field :font_family, :string
    field :bold, :boolean, default: false
    field :text_color, :string
    field :element_text_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text_style, attrs) do
    element_text_style
    |> cast(attrs, [:alignment, :font_size, :font_family, :bold, :italic, :italic, :underline, :text_color])
    |> validate_required([:alignment, :font_size, :font_family, :bold, :italic, :italic, :underline, :text_color])
    |> unique_constraint(:element_text_id)
  end
end
