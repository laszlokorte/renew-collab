defmodule RenewCollab.Element.ElementText do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text" do
    field :body, :string
    belongs_to :element, RenewCollab.Renew.Element
    has_one :style, RenewCollab.Style.ElementTextStyle, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text, attrs) do
    element_text
    |> cast(attrs, [:body])
    |> cast_assoc(:style)
    |> validate_required([:body])
    |> unique_constraint(:element_id)
  end
end
