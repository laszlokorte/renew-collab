defmodule RenewCollabCtrl.View do
  alias RenewCollabCtrl.Views

  def do_fetch(_account, %Views.DocumentLayerRelative{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.DocumentStripped{
        document_id: document_id,
        original_ids: original_ids
      }) do
    %{document_id: document_id, original_ids: original_ids}
    |> RenewCollab.Queries.StrippedDocument.new()
    |> RenewCollab.Queries.StrippedDocument.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.DocumentVersionState{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.UndoRedoState.new()
    |> RenewCollab.Queries.UndoRedoState.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.DocumentVersionsList{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentVersions.new()
    |> RenewCollab.Queries.DocumentVersions.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.DocumentWithContent{
        document_id: document_id,
        root_layer_id: root_layer_id
      }) do
    %{document_id: document_id, root_layer_id: root_layer_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.Queries.DocumentWithElements.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
    |> then(
      &case &1 do
        {:ok, list} -> {:ok, RenewCollabProj.Projects.attach_project_assignment(list)}
      end
    )
  end

  def do_fetch(_account, %Views.DocumentWithThumbnailContent{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentWithThumbnailElements.new()
    |> RenewCollab.Queries.DocumentWithThumbnailElements.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
    |> then(
      &case &1 do
        {:ok, list} -> {:ok, RenewCollabProj.Projects.attach_project_assignment(list)}
      end
    )
  end

  def do_fetch(_account, %Views.DocumentHierarchyMissings{document_id: document_id}) do
    RenewCollab.Hierarchy.find_missing(document_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.DocumentHierarchyInvalids{document_id: document_id}) do
    RenewCollab.Hierarchy.find_missing(document_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.DocumentSimulationLinks{document_id: document_id}) do
    RenewCollab.Renew.list_simulation_links(document_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalAccounts{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalDocumentCount{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalDocumentsList{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalPrimitives{}) do
    RenewCollab.Primitives.find_all()
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalShadowNetsList{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSimulationsList{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSocketById{}) do
    RenewCollab.Queries.SocketsById.new()
    |> RenewCollab.Queries.SocketsById.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.GlobalSocketIdsByName{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasList{}) do
    RenewCollab.Queries.SocketSchemasList.new()
    |> RenewCollab.Queries.SocketSchemasList.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.GlobalSocketSchema{socket_schema_id: id}) do
    {:ok, RenewCollab.Sockets.find_socket_schema(id)}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasNames{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSymbolsList{}) do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.Queries.ListSymbols.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.GlobalSymbol{symbol_id: id}) do
    RenewCollab.Symbols.find_symbol(id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalSymbolsNames{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSyntaxList{}) do
    {:ok, RenewCollab.Syntax.find_all()}
  end

  def do_fetch(_account, %Views.MyAccount{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.MyProjectsList{}) do
    {:error, :not_implemented}
  end

  def do_fetch(account, %Views.ProjectDocumentsList{project_id: project_id}) do
    account
    |> RenewCollabProj.Projects.find_own_project(project_id)
    |> then(&RenewCollab.Queries.DocumentList.new(%{project: &1}))
    |> RenewCollab.Queries.DocumentList.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.ProjectShadowNetSystemsList{project_id: project_id}) do
    RenewCollabSim.Simulator.list_shadow_net_systems(
      RenewCollabProj.Projects.list_project_shadow_net_systems(project_id)
    )
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.ProjectSimulationsList{project_id: project_id}) do
    RenewCollabSim.Simulator.list_simulations(
      RenewCollabProj.Projects.list_project_simulations(project_id)
    )
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.ShadowNetSystem{shadow_net_system_id: shadow_net_system_id}) do
    RenewCollabSim.Simulator.find_shadow_net_system(shadow_net_system_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.ShadowNetSystemSimulations{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.SimulationWithState{simulation_id: simulation_id}) do
    RenewCollabSim.Simulator.find_simulation(simulation_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.SystemHealthReport{}) do
    %{
      installed_socket_schema:
        RenewCollab.Queries.SocketSchemasList.new()
        |> RenewCollab.Queries.SocketSchemasList.multi()
        |> RenewCollab.Repo.transact()
        |> then(fn {:ok, r} -> r end),
      installed_symbols:
        RenewCollab.Queries.SymbolIdsByName.new()
        |> RenewCollab.Queries.SymbolIdsByName.multi()
        |> RenewCollab.Repo.transact()
        |> then(fn {:ok, r} -> r end),
      number_of_accounts: RenewCollabAuth.Auth.count_accounts(),
      number_of_sessions: RenewCollabAuth.Auth.count_sessions(),
      number_of_media: RenewCollab.Media.count(),
      number_of_documents:
        RenewCollab.Queries.DocumentCount.new()
        |> RenewCollab.Queries.DocumentCount.multi()
        |> RenewCollab.Repo.transact()
        |> extract_result()
        |> then(fn {:ok, r} -> r end),
      number_of_snapshots: RenewCollab.Renew.count_snapshots(),
      number_of_shadow_net_systems: RenewCollabSim.Simulator.count_shadow_net_systems(),
      number_of_simulations: RenewCollabSim.Simulator.count_simulations(),
      number_of_projects: RenewCollabProj.Projects.count_projects(),
      hierarchy_missing_count: RenewCollab.Hierarchy.count_missing_global(),
      hierarchy_invalid_count: RenewCollab.Hierarchy.count_invalids_global(),
      cache_size: RenewCollabCtrl.CacheServer.size(),
      simulation_active_count: RenewCollabSim.Server.ProjectSimulationServer.count_all(),
      formalisms: RenewCollabSim.Compiler.SnsCompiler.formalisms()
    }
    |> then(&{:ok, &1})
  end

  defp extract_result({:ok, %{:result => res}}) do
    {:ok, res}
  end
end
