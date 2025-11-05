defmodule RenewCollabProj.Queries.ProjectInvitations do
  alias RenewCollabProj.Entities.ProjectInvitation
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(
        i in ProjectInvitation,
        where: i.project_id == ^project_id,
        order_by: [asc: i.inserted_at]
      )
    )
  end
end
