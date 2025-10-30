defmodule RenewCollabSim.Commands.CreateSimulation do
  alias RenewCollabSim.Entites.Simulation
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:sim, %Simulation{shadow_net_system_id: sns_id})
  end
end
