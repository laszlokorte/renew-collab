defmodule RenewCollab.Renew.ElementText do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text" do
    field :body, :string
    field :element_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text, attrs) do
    element_text
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> unique_constraint(:element_id)
  end
end
