defmodule RenewCollabSim.Commands.CreateSimulation do
  alias RenewCollabSim.Entities.Simulation

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id}
  end

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:simulation, %Simulation{shadow_net_system_id: sns_id})
  end
end
