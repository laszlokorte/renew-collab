defmodule RenewCollabProj.Commands.CreateProject do
  alias RenewCollabProj.Entities.Project

  defstruct [:name, :owner_account_id]

  def new(%{name: name, owner_account_id: owner_account_id}) do
    %__MODULE__{name: name, owner_account_id: owner_account_id}
  end

  def multi(%__MODULE__{name: name, owner_account_id: nil}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :project,
      %Project{}
      |> Project.creation_changeset(%{
        name: name
      })
    )
  end

  def multi(%__MODULE__{name: name, owner_account_id: owner_account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :project,
      %Project{}
      |> Project.creation_changeset(%{
        name: name,
        ownerships: [%{account_id: owner_account_id, role: :owner}]
      })
    )
  end
end
