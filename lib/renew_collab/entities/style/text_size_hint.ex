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
end
