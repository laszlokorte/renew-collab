defmodule RenewCollabProj.Queries.AccountProjectInvitations do
  alias RenewCollabProj.Entities.ProjectInvitation
  import Ecto.Query

  defstruct [:account_id]

  def new(%{account_id: account_id}) do
    %__MODULE__{account_id: account_id}
  end

  def multi(%__MODULE__{account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(
        i in ProjectInvitation,
        join: p in assoc(i, :project),
        left_join: m in assoc(i, :membership),
        on: m.account_id == i.account_id,
        where: i.account_id == ^account_id and is_nil(m.id),
        order_by: [asc: i.inserted_at],
        preload: [project: p, membership: m]
      )
    )
  end
end
