defmodule RenewCollabSim.Queries.ShadowNetSystemsSimulations do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(s in Simulation,
        where: s.shadow_net_system_id == ^sns_id,
        order_by: [desc: s.inserted_at]
      )
    )
  end
end
