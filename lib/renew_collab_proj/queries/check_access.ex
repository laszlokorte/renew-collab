defmodule RenewCollabProj.Queries.CheckAccess do
  alias RenewCollabProj.Entities.ProjectMember
  import Ecto.Query
  defstruct [:account_id, :entity, :roles]

  def new(%{account_id: account_id, entity: entity, roles: roles}) do
    %__MODULE__{account_id: account_id, entity: entity, roles: roles}
  end

  def multi(%__MODULE__{account_id: account_id, entity: entity, roles: roles}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      entity
      |> case do
        {:project, proj_id} ->
          from(m in ProjectMember,
            where: m.account_id == ^account_id and m.project_id == ^proj_id and m.role in ^roles,
            select: not is_nil(m.account_id),
            limit: 1
          )

        {:document, doc_id} ->
          from(m in ProjectMember,
            join: p in assoc(m, :project),
            join: d in assoc(p, :documents),
            where: m.account_id == ^account_id and d.document_id == ^doc_id and m.role in ^roles,
            select: not is_nil(m.account_id),
            limit: 1
          )

        {:simulation, sim_id} ->
          from(m in ProjectMember,
            join: p in assoc(m, :project),
            join: s in assoc(p, :simulations),
            where:
              m.account_id == ^account_id and s.simulation_id == ^sim_id and m.role in ^roles,
            select: not is_nil(m.account_id),
            limit: 1
          )

        {:shadow_net_system, sns_id} ->
          from(m in ProjectMember,
            join: p in assoc(m, :project),
            join: s in assoc(p, :shadow_net_systems),
            where:
              m.account_id == ^account_id and s.shadow_net_system_id == ^sns_id and
                m.role in ^roles,
            select: not is_nil(m.account_id),
            limit: 1
          )
      end
    )
  end
end
