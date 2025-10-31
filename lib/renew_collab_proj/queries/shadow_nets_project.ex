defmodule RenewCollabProj.Queries.ShadowNetsProject do
  alias RenewCollabProj.Entities.ProjectShadowNetSystem
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: shadow_net_system_id}) do
    %__MODULE__{shadow_net_system_id: shadow_net_system_id}
  end

  def multi(%__MODULE__{shadow_net_system_id: shadow_net_system_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in ProjectShadowNetSystem,
        join: proj in assoc(p, :project),
        where: p.shadow_net_system_id == ^shadow_net_system_id
      )
    )
  end
end
