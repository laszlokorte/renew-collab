defmodule RenewCollabProj.Commands.AssignInvitationsToNewAccount do
  alias RenewCollabProj.Entities.ProjectInvitation

  import Ecto.Query
  defstruct [:account_id, :email]

  def new(%{account_id: account_id, email: email}) do
    %__MODULE__{account_id: account_id, email: email}
  end

  def multi(%__MODULE__{account_id: account_id, email: email}) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      :invitations,
      from(i in ProjectInvitation,
        where: i.email == ^email,
        update: [set: [account_id: ^account_id]]
      ),
      []
    )
  end
end
