defmodule RenewCollab.Element.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text" do
    field :position_x, :float
    field :position_y, :float
    field :body, :string, default: ""
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    has_one :style, RenewCollab.Style.TextStyle, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text, attrs) do
    element_text
    |> cast(attrs, [:position_x, :position_y, :body])
    |> cast_assoc(:style)
    |> validate_required([:position_x, :position_y])
    |> unique_constraint(:element_id)
  end

  def change_position(element_text, attrs) do
    element_text
    |> cast(attrs, [
      :position_x,
      :position_y
    ])
  end
end
