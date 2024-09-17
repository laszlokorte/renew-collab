defmodule RenewCollab.Connection.Hyperlink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hyperlink" do
    belongs_to :source_layer, RenewCollab.Hierarchy.Layer
    belongs_to :target_layer, RenewCollab.Hierarchy.Layer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hyperlink, attrs) do
    hyperlink
    |> cast(attrs, [:source_layer_id, :target_layer_id])
    |> validate_required([:source_layer_id, :target_layer_id])
    |> unique_constraint(:source_layer_id)
  end
end
