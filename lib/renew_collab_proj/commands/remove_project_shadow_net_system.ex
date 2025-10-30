defmodule RenewCollabProj.Commands.RemoveProjectShadowNetSystem do
  alias RenewCollabProj.Entities.ProjectShadowNetSystem
  import Ecto.Query

  defstruct [:project_id, :shadow_net_system_id]

  def new(%{project_id: project_id, shadow_net_system_id: shadow_net_system_id}) do
    %__MODULE__{project_id: project_id, shadow_net_system_id: shadow_net_system_id}
  end

  def multi(%__MODULE__{project_id: project_id, shadow_net_system_id: shadow_net_system_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(a in ProjectShadowNetSystem,
        where: a.project_id == ^project_id and a.shadow_net_system_id == ^shadow_net_system_id
      ),
      []
    )
  end
end
