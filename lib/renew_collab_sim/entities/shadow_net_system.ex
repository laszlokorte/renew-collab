defmodule RenewCollabSim.Entities.ShadowNetSystem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shadow_net_system" do
    field :label, :string, default: nil
    field :compiled, :binary
    field :main_net_name, :string
    field :simulation_count, :integer, virtual: true
    has_many :nets, RenewCollabSim.Entities.ShadowNet, preload_order: [asc: :id]
    has_many :simulations, RenewCollabSim.Entities.Simulation, preload_order: [desc: :inserted_at]

    has_one :project_assignment, RenewCollabProj.Entities.ProjectShadowNetSystem
    has_one :project, through: [:project_assignment, :project]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shadow_net_sytem, attrs) do
    shadow_net_sytem
    |> cast(attrs, [:compiled, :main_net_name])
    |> cast(attrs, [:label], empty_values: [""])
    |> cast_assoc(:nets)
    |> validate_required([:compiled, :main_net_name])
  end

  @doc false
  def main_net_changeset(shadow_net_sytem, attrs) do
    shadow_net_sytem
    |> cast(attrs, [:main_net])
    |> validate_required([:main_net])
  end

  @doc false
  def rename_changeset(shadow_net_sytem, attrs) do
    shadow_net_sytem
    |> cast(attrs, [:label], empty_values: [""])
  end
end
