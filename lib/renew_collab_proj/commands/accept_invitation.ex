defmodule RenewCollabProj.Commands.AcceptInvitation do
  alias RenewCollabProj.Entities.ProjectMember
  alias RenewCollabProj.Entities.ProjectInvitation
  import Ecto.Query

  defstruct [:project_id, :invitation_id]

  def new(%{project_id: project_id, invitation_id: invitation_id}) do
    %__MODULE__{project_id: project_id, invitation_id: invitation_id}
  end

  def multi(%__MODULE__{project_id: project_id, invitation_id: invitation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :find_invitation,
      from(a in ProjectInvitation,
        where: a.project_id == ^project_id and a.id == ^invitation_id
      ),
      []
    )
    |> Ecto.Multi.insert(
      :add_member,
      fn %{find_invitation: inv} ->
        %ProjectMember{project_id: inv.project_id, account_id: inv.account_id, role: inv.role}
      end
    )
    |> Ecto.Multi.delete_all(
      :delete_invitaion,
      from(a in ProjectInvitation,
        where: a.project_id == ^project_id and a.id == ^invitation_id
      ),
      []
    )
  end
end
