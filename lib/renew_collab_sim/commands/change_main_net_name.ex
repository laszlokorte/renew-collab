defmodule RenewCollabSim.Commands.ChangeMainNetName do
  alias RenewCollabSim.Entites.ShadowNetSystem
  import Ecto.Query

  defstruct [:shadow_net_system_id, :main_net]

  def new(%{shadow_net_system_id: sns_id, main_net: main_net}) do
    %__MODULE__{shadow_net_system_id: sns_id, main_net: main_net}
  end

  def multi(%__MODULE__{shadow_net_system_id: sns_id, main_net: main_net}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:sns, from(sns in ShadowNetSystem, where: sns.id == ^sns_id))
    |> Ecto.Multi.update(:change_main_net, fn _, %{sns: sns} ->
      ShadowNetSystem.main_net_changeset(sns, main_net)
    end)
  end
end
