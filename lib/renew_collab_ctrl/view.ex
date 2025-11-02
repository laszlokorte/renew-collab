defmodule RenewCollabCtrl.View do
  alias RenewCollabCtrl.Views

  def do_fetch(_account, %Views.DocumentLayerRelative{
        document_id: document_id,
        layer_id: layer_id,
        relative: relative,
        id_only: id_only
      }) do
    %{document_id: document_id, layer_id: layer_id, relative: relative, id_only: id_only}
    |> RenewCollab.Queries.LayerHierarchyRelative.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentStripped{
        document_id: document_id,
        original_ids: original_ids
      }) do
    %{document_id: document_id, original_ids: original_ids}
    |> RenewCollab.Queries.StrippedDocument.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentVersionState{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.UndoRedoState.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentVersionsList{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentVersions.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentWithContent{
        document_id: document_id,
        root_layer_id: root_layer_id
      }) do
    %{document_id: document_id, root_layer_id: root_layer_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> case do
      {:ok, document} ->
        RenewCollabProj.Queries.DocumentsProject.new(%{document_id: document.id})
        |> RenewCollabProj.ProjectFetcher.fetch()
        |> case do
          {:ok, assignment} ->
            {:ok, document |> Map.put(:project_assignment, assignment)}

          _ ->
            {:ok, document}
        end
    end
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

  def do_fetch(_account, %Views.GlobalProjects{}) do
    RenewCollabProj.Queries.AllProjects.new(%{})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalProject{project_id: project_id}) do
    %{project_id: project_id}
    |> RenewCollabProj.Queries.ProjectDetails.new()
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalAccounts{}) do
    RenewCollabAuth.Queries.AllAccounts.new(%{})
    |> RenewCollabAuth.AuthFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalDocumentCount{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalDocumentsList{}) do
    RenewCollab.Queries.DocumentList.new(%{document_ids: :all})
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalPrimitives{}) do
    RenewCollab.Primitives.find_all()
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalSimulationsList{}) do
    RenewCollabSim.Queries.ListSimulations.new(%{simulation_ids: :all})
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalShadowNetSystemsList{}) do
    RenewCollabSim.Queries.ListShadowNetSystems.new(%{shadow_net_system_ids: :all})
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalSocketById{}) do
    RenewCollab.Queries.SocketsById.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalSocketIdsByName{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasList{}) do
    RenewCollab.Queries.SocketSchemasList.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalSocketSchema{socket_schema_id: id}) do
    {:ok, RenewCollab.Sockets.find_socket_schema(id)}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasNames{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSymbolsList{}) do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.DocumentFetcher.fetch()
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

  def do_fetch(_account, %Views.MyProjectsList{account_id: account_id}) do
    %{account_id: account_id}
    |> RenewCollabProj.Queries.OwnProjects.new()
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.MyProject{account_id: account_id, project_id: project_id}) do
    %{account_id: account_id, project_id: project_id}
    |> RenewCollabProj.Queries.ProjectDetails.new()
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.ProjectMembersList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectDetails.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %RenewCollabProj.Entities.Project{members: members}} ->
        {:ok, accounts} =
          members
          |> Enum.map(fn %{account_id: id} -> id end)
          |> then(&%{account_ids: &1})
          |> RenewCollabAuth.Queries.AccountsWithIds.new()
          |> RenewCollabAuth.AuthFetcher.fetch()

        accounts_by_id = Map.new(accounts, &{&1.id, &1})

        members
        |> Enum.map(fn member ->
          case Map.fetch(accounts_by_id, member.account_id) do
            {:ok, account} ->
              %{member | account: account} |> Ecto.put_meta(state: :loaded)

            :error ->
              # leave as-is if the post isn’t in the loaded list
              member
          end
        end)
        |> then(&{:ok, &1})
    end
  end

  def do_fetch(_account, %Views.ProjectDocumentsList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectDetails.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %RenewCollabProj.Entities.Project{documents: documents}} ->
        documents |> Enum.map(fn %{document_id: id} -> id end) |> then(&%{document_ids: &1})
    end
    |> RenewCollab.Queries.DocumentList.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.ProjectShadowNetSystemsList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectDetails.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %RenewCollabProj.Entities.Project{shadow_net_systems: shadow_net_systems}} ->
        shadow_net_systems
        |> Enum.map(fn %{shadow_net_system_id: id} -> id end)
        |> then(&%{shadow_net_system_ids: &1})
    end
    |> RenewCollabSim.Queries.ListShadowNetSystems.new()
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.ProjectSimulationsList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectDetails.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %RenewCollabProj.Entities.Project{simulations: simulations}} ->
        simulations |> Enum.map(fn %{simulation_id: id} -> id end) |> then(&%{simulation_ids: &1})
    end
    |> RenewCollabSim.Queries.ListSimulations.new()
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.ShadowNetSystem{shadow_net_system_id: shadow_net_system_id}) do
    RenewCollabSim.Queries.ShadowNetSystem.new(%{
      shadow_net_system_id: shadow_net_system_id,
      detailed: true
    })
    |> RenewCollabSim.SimulationFetcher.fetch()
    |> case do
      {:ok, shadow_net_system} ->
        RenewCollabProj.Queries.ShadowNetsProject.new(%{
          shadow_net_system_id: shadow_net_system.id
        })
        |> RenewCollabProj.ProjectFetcher.fetch()
        |> case do
          {:ok, assignment} ->
            {:ok, shadow_net_system |> Map.put(:project_assignment, assignment)}

          _ ->
            {:ok, shadow_net_system}
        end
    end
  end

  def do_fetch(_account, %Views.ShadowNetSystemSimulations{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.SimulationWithState{simulation_id: simulation_id}) do
    RenewCollabSim.Queries.Simulation.new(%{simulation_id: simulation_id, detailed: true})
    |> RenewCollabSim.SimulationFetcher.fetch()
    |> case do
      {:ok, simulation} ->
        RenewCollabProj.Queries.SimulationsProject.new(%{simulation_id: simulation.id})
        |> RenewCollabProj.ProjectFetcher.fetch()
        |> case do
          {:ok, assignment} ->
            {:ok, simulation |> Map.put(:project_assignment, assignment)}

          _ ->
            {:ok, simulation}
        end
    end
  end

  def do_fetch(_account, %Views.SystemHealthReport{}) do
    %{
      installed_socket_schema:
        RenewCollab.Queries.SocketSchemasList.new()
        |> RenewCollab.DocumentFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      installed_symbols:
        RenewCollab.Queries.SymbolIdsByName.new()
        |> RenewCollab.DocumentFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      number_of_accounts: RenewCollabAuth.Auth.count_accounts(),
      number_of_sessions: RenewCollabAuth.Auth.count_sessions(),
      number_of_media: RenewCollab.Media.count(),
      number_of_documents:
        RenewCollab.Queries.DocumentCount.new()
        |> RenewCollab.DocumentFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      number_of_snapshots: RenewCollab.Renew.count_snapshots(),
      number_of_shadow_net_systems:
        RenewCollabSim.Queries.CountShadowNetSystems.new(%{})
        |> RenewCollabSim.SimulationFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      number_of_simulations:
        RenewCollabSim.Queries.CountSimulations.new(%{})
        |> RenewCollabSim.SimulationFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      number_of_projects:
        RenewCollabProj.Queries.CountProjects.new(%{})
        |> RenewCollabProj.ProjectFetcher.fetch()
        |> then(fn {:ok, r} -> r end),
      hierarchy_missing_count: RenewCollab.Hierarchy.count_missing_global(),
      hierarchy_invalid_count: RenewCollab.Hierarchy.count_invalids_global(),
      cache_size: RenewCollabCtrl.CacheServer.size(),
      simulation_active_count: RenewCollabSim.Server.ProjectSimulationServer.count_all(),
      formalisms: RenewCollabSim.Compiler.SnsCompiler.formalisms()
    }
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalProjectAllAssignments{}) do
    RenewCollabProj.Queries.AllProjectAssignments.new(%{})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end
end
