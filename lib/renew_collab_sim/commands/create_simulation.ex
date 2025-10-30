defmodule RenewCollabSim.Commands.CreateSimulation do
  alias RenewCollabSim.Entities.Simulation

  defstruct [:shadow_net_system_id, :document_ids]

  def new(%{shadow_net_system_id: sns_id, document_ids: document_ids}) do
    %__MODULE__{shadow_net_system_id: sns_id, document_ids: document_ids}
  end

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id, document_ids: []}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id, document_ids: _document_ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:sim, %Simulation{shadow_net_system_id: sns_id})

    # TODO create simulation links
  end
end
