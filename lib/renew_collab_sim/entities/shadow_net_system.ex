defmodule RenewCollabSim.Entites.ShadowNetSystem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shadow_net_system" do
    field :compiled, :binary
    field :main_net_name, :string
    has_many :nets, RenewCollabSim.Entites.ShadowNet
    has_many :simulations, RenewCollabSim.Entites.Simulation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shadow_net_sytem, attrs) do
    shadow_net_sytem
    |> cast(attrs, [:compiled, :main_net_name])
    |> cast_assoc(:nets)
    |> validate_required([:compiled, :main_net_name])
  end
end
