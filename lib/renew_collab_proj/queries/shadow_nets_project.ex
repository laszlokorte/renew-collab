defmodule RenewCollabProj.Queries.ShadowNetsProject do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: shadow_net_system_id}) do
    %__MODULE__{shadow_net_system_id: shadow_net_system_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: shadow_net_system_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in Project,
        join: sns in assoc(p, :shadow_net_systems),
        where: sns.shadow_net_system_id == ^shadow_net_system_id
      )
    )
  end
end
