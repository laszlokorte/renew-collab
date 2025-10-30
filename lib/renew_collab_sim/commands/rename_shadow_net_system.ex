defmodule RenewCollabSim.Commands.RenameShadowNetSystem do
  alias RenewCollabSim.Entities.ShadowNetSystem
  import Ecto.Query

  defstruct [:shadow_net_system_id, :new_name]

  def new(%{shadow_net_system_id: id, new_name: new_name}) do
    %__MODULE__{shadow_net_system_id: id, new_name: new_name}
  end

  def multi(%__MODULE__{shadow_net_system_id: id, new_name: new_name}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:sns, from(s in ShadowNetSystem, where: s.id == ^id))
    |> Ecto.Multi.update(:rename, fn %{sns: sns} ->
      sns |> ShadowNetSystem.rename_changeset(%{label: new_name})
    end)
  end
end
