defmodule RenewCollabProj.Queries.AllProjectAssignments do
  alias RenewCollabProj.Entities.ProjectMember
  alias RenewCollabProj.Entities.ProjectShadowNetSystem
  alias RenewCollabProj.Entities.ProjectSimulation
  alias RenewCollabProj.Entities.ProjectDocument
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :documents,
      from(
        d in ProjectDocument,
        select: d.document_id
      )
    )
    |> Ecto.Multi.all(
      :simulations,
      from(
        d in ProjectSimulation,
        select: d.simulation_id
      )
    )
    |> Ecto.Multi.all(
      :shadow_net_systems,
      from(
        d in ProjectShadowNetSystem,
        select: d.shadow_net_system_id
      )
    )
    |> Ecto.Multi.all(
      :members,
      from(
        d in ProjectMember,
        select: d.account_id
      )
    )
    |> Ecto.Multi.run(
      :result,
      fn _, %{documents: docs, simulations: sims, shadow_net_systems: sns, members: mems} ->
        %{
          documents: MapSet.new(docs),
          simulations: MapSet.new(sims),
          shadow_net_systems: MapSet.new(sns),
          members: MapSet.new(mems)
        }
        |> then(&{:ok, &1})
      end
    )
  end
end
