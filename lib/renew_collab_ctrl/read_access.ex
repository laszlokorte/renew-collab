defmodule RenewCollabCtrl.ReadAccess do
  alias RenewCollabCtrl.Views
  def can(_, _)

  def can(%{id: account_id}, %Views.ProjectMembersList{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.ProjectDocumentsList{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.DocumentWithContent{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentVersionsList{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentVersionState{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentStripped{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentSimulationLinks{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{}, %Views.GlobalSocketSchemasList{}), do: true
  def can(%{}, %Views.GlobalSocketSchemasMap{}), do: true
  def can(%{}, %Views.GlobalSocketSchema{}), do: true
  def can(%{}, %Views.GlobalSocketById{}), do: true
  def can(%{}, %Views.GlobalSymbolsList{}), do: true
  def can(%{}, %Views.GlobalSymbolsMap{}), do: true
  def can(%{}, %Views.GlobalSymbol{}), do: true
  def can(%{}, %Views.GlobalSyntaxList{}), do: true
  def can(%{}, %Views.GlobalPrimitives{}), do: true

  def can(%{id: account_id}, %Views.DocumentHierarchyMissings{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentHierarchyInvalids{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.DocumentLayerRelative{document_id: doc_id}),
    do: can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Views.MyProjectsList{account_id: account_id}), do: true
  def can(%{id: account_id}, %Views.MyProject{account_id: account_id}), do: true

  def can(%{id: account_id}, %Views.ProjectSimulationsList{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.ProjectShadowNetSystemsList{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.ProjectRunningSimulationIds{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.SimulationIsActive{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.SimulationIsPlaying{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.ShadowNetSystem{shadow_net_system_id: sns_id}),
    do: can_read(account_id, :shadow_net_system, sns_id)

  def can(%{id: account_id}, %Views.SimulationWithState{simulation_id: sim_id}),
    do: can_read(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Views.SimulationWithLogEntries{simulation_id: sim_id}),
    do: can_read(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Views.SimulationNetInstance{net_instance_id: net_instance_id}),
    do: can_read(account_id, :net_instance, net_instance_id)

  def can(%{id: account_id}, %Views.ProjectInvitations{project_id: proj_id}),
    do: can_read(account_id, :project, proj_id)

  def can(%{id: account_id}, %Views.MyProjectInvitations{account_id: account_id}), do: true

  def can(%{id: account_id}, %Views.MediaData{media_id: media_id}),
    do: can_read(account_id, :media, media_id)

  # TODO add auth protection for reading media
  # currently we want to embed media objects via <img src="">
  # but then the browser does not send any auth headers (we do not used cookies)
  # so we can not auth the user
  def can(_, %Views.MediaData{}), do: true

  def can(%{id: account_id}, %Views.ShadowNetSystemSimulations{
        shadow_net_system_id: sns_id
      }),
      do: can_read(account_id, :shadow_net_system, sns_id)

  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalProject{}), do: true
  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalDocumentsList{}), do: true
  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalSimulationsList{}), do: true
  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalShadowNetSystemsList{}), do: true

  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalProjectAllAssignments{}),
    do: true

  def can(%{id: _acc_id, is_admin: true}, %Views.SystemHealthReport{}), do: true
  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalAccounts{}), do: true
  def can(%{id: _acc_id, is_admin: true}, %Views.GlobalProjects{}), do: true
  def can(_account, _view), do: false

  def can_read(account_id, :project, proj_id),
    do: check_access(account_id, {:project, proj_id}, [:reader, :editor, :owner])

  def can_read(account_id, :simulation, sim_id),
    do: check_access(account_id, {:simulation, sim_id}, [:reader, :editor, :owner])

  def can_read(account_id, :shadow_net_system, sns_id),
    do: check_access(account_id, {:shadow_net_system, sns_id}, [:reader, :editor, :owner])

  def can_read(account_id, :document, doc_id),
    do: check_access(account_id, {:document, doc_id}, [:reader, :editor, :owner])

  def can_read(account_id, :media, media_id),
    do: check_access(account_id, {:media, media_id}, [:reader, :editor, :owner])

  def can_read(account_id, :net_instance, net_instance_id) do
    RenewCollabSim.Queries.SimulationNetInstanceSimple.new(%{
      net_instance_id: net_instance_id
    })
    |> RenewCollabSim.SimulationFetcher.fetch()
    |> case do
      {:ok, %{simulation_id: sim_id}} -> can_read(account_id, :simulation, sim_id)
      _ -> false
    end
  end

  defp check_access(account_id, entity, roles) do
    RenewCollabProj.Queries.CheckAccess.new(%{
      account_id: account_id,
      entity: entity,
      roles: roles
    })
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, result} -> result
      _ -> false
    end
  end
end
