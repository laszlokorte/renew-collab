defmodule RenewCollabSim.Commands.DeleteShadowNetSystem do
  alias RenewCollabSim.Entities.ShadowNetSystem
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{shadow_net_system_id: sns_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_sns, from(s in ShadowNetSystem, where: s.id == ^sns_id))
  end
end
