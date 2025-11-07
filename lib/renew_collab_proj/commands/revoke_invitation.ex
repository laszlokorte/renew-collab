defmodule RenewCollabProj.Commands.RevokeInvitation do
  alias RenewCollabProj.Entities.ProjectInvitation
  import Ecto.Query

  defstruct [:project_id, :inviation_or_account_id]

  def new(%{project_id: project_id, invitation_id: invitation_id}) do
    %__MODULE__{project_id: project_id, inviation_or_account_id: {:invitation, invitation_id}}
  end

  def new(%{project_id: project_id, account_id: account_id}) do
    %__MODULE__{project_id: project_id, inviation_or_account_id: {:account, account_id}}
  end

  def multi(%__MODULE__{
        project_id: project_id,
        inviation_or_account_id: {:invitation, invitation_id}
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :invitation,
      from(a in ProjectInvitation,
        where: a.project_id == ^project_id and a.id == ^invitation_id
      )
    )
    |> Ecto.Multi.delete(
      :delete_invitaion,
      fn %{invitation: inv} -> inv end
    )
  end

  def multi(%__MODULE__{
        project_id: project_id,
        inviation_or_account_id: {:account, account_id}
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :invitation,
      from(a in ProjectInvitation,
        where: a.project_id == ^project_id and a.account_id == ^account_id
      )
    )
    |> Ecto.Multi.delete(
      :delete_invitaion,
      fn %{invitation: inv} -> inv end
    )
  end
end
