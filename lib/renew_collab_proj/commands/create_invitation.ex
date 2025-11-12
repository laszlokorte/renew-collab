defmodule RenewCollabProj.Commands.CreateInvitation do
  alias RenewCollabProj.Entities.ProjectInvitation
  defstruct [:project_id, :email, :role, :account_id]

  def new(%{project_id: project_id, email: email, role: role, account_id: account_id}) do
    %__MODULE__{project_id: project_id, email: email, role: role, account_id: account_id}
  end

  def multi(%__MODULE__{project_id: project_id, email: email, role: role, account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :invitation,
      %ProjectInvitation{}
      |> ProjectInvitation.changeset(%{
        project_id: project_id,
        email: email,
        role: role,
        account_id: account_id
      })
    )
  end
end
