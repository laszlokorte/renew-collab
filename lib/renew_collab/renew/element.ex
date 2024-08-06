defmodule RenewCollab.Renew.Element do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element" do
    field :z_index, :integer
    field :position_x, :float
    field :position_y, :float
    belongs_to :document, RenewCollab.Renew.Document

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:z_index, :position_x, :position_y])
    |> validate_required([:z_index, :position_x, :position_y])
  end
end
