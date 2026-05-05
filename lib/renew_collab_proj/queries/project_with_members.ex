defmodule RenewCollabProj.Queries.ProjectWithMembers do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:id]

  def new(%{project_id: project_id}) do
    %__MODULE__{id: {:project, project_id}}
  end

  def new(%{document_id: document_id}) do
    %__MODULE__{id: {:document, document_id}}
  end

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{id: {:simulation, simulation_id}}
  end

  def new(%{shadow_net_system_id: sns_id}) do
    %__MODULE__{id: {:shadow_net_system, sns_id}}
  end

  def multi(%__MODULE__{id: {:project, project_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :projects,
      from(
        p in Project,
        where: p.id == ^project_id
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members
       ])}
    end)
  end

  def multi(%__MODULE__{id: {:document, document_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :projects,
      from(
        p in Project,
        inner_join: d in assoc(p, :documents),
        on: d.document_id == ^document_id
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members
       ])}
    end)
  end

  def multi(%__MODULE__{id: {:simulation, simulation_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :projects,
      from(
        p in Project,
        inner_join: s in assoc(p, :simulations),
        on: s.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members
       ])}
    end)
  end

  def multi(%__MODULE__{id: {:shadow_net_system, shadow_net_system_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :projects,
      from(
        p in Project,
        inner_join: s in assoc(p, :shadow_net_systems),
        on: s.shadow_net_system_id == ^shadow_net_system_id
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members
       ])}
    end)
  end
end
