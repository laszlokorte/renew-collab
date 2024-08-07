defmodule RenewCollab.Renew.ElementBox do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_box" do
    field :width, :float
    field :height, :float
    field :element_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_box, attrs) do
    element_box
    |> cast(attrs, [:width, :height])
    |> validate_required([:width, :height])
    |> unique_constraint(:element_id)
  end
end
