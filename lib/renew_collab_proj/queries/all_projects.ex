defmodule RenewCollabProj.Queries.AllProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :projects,
      from(p in Project,
        order_by: [desc: :inserted_at]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members,
         :ownerships,
         :documents,
         :shadow_net_systems,
         :simulations
       ])}
    end)
  end
end
