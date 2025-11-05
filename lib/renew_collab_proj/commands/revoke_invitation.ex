defmodule RenewCollabProj.Commands.RevokeInvitation do
  alias RenewCollabProj.Entities.ProjectInvitation
  import Ecto.Query

  defstruct [:project_id, :invitation_id]

  def new(%{project_id: project_id, invitation_id: invitation_id}) do
    %__MODULE__{project_id: project_id, invitation_id: invitation_id}
  end

  def multi(%__MODULE__{project_id: project_id, invitation_id: invitation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_invitaion,
      from(a in ProjectInvitation,
        where: a.project_id == ^project_id and a.id == ^invitation_id
      ),
      []
    )
  end
end
