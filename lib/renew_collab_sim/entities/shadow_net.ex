defmodule RenewCollabSim.Entites.ShadowNet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shadow_net" do
    field :name, :string
    field :document_json, :binary
    belongs_to :shadow_net_system, RenewCollabSim.Entites.ShadowNetSystem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shadow_net, attrs) do
    shadow_net
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
