defmodule RenewCollabProj.Commands.AssignProjectShadowNetSystem do
  alias RenewCollabProj.Entities.ProjectShadowNetSystem

  defstruct [:project_id, :shadow_net_system_id]

  def new(%{project_id: project_id, shadow_net_system_id: shadow_net_system_id}) do
    %__MODULE__{project_id: project_id, shadow_net_system_id: shadow_net_system_id}
  end

  def multi(%__MODULE__{project_id: project_id, shadow_net_system_id: shadow_net_system_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_assignment, %ProjectShadowNetSystem{
      project_id: project_id,
      shadow_net_system_id: shadow_net_system_id
    })
  end
end
