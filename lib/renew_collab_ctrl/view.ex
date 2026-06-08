defmodule RenewCollabCtrl.View do
  alias RenewCollab.Media
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

  def do_fetch(_account, %Views.DocumentLayerHyperlinked{
        document_id: document_id,
        layer_id: layer_id,
        deep: deep
      }) do
    %{document_id: document_id, layer_id: layer_id, deep: deep}
    |> RenewCollab.Queries.LayerHyperlinked.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentLayerGraphConnection{
        document_id: document_id,
        layer_id: layer_id,
        rel: rel
      }) do
    %{document_id: document_id, layer_id: layer_id, rel: rel}
    |> RenewCollab.Queries.LayerGraphRelation.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentLayerRelativeMultiple{
        document_id: document_id,
        layer_id: layer_id,
        rel: rel
      }) do
    %{document_id: document_id, layer_id: layer_id, rel: rel}
    |> RenewCollab.Queries.LayerHierarchyRelativeMultiple.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.DocumentLayerConnectedComponent{
        document_id: document_id,
        layer_id: layer_id
      }) do
    %{document_id: document_id, layer_id: layer_id}
    |> RenewCollab.Queries.LayerHierarchyConnectedComponent.new()
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

  def do_fetch(
        _account,
        %Views.DocumentWithContent{
          document_id: _document_id
        } = doc
      ) do
    doc
    # TODO
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
    |> case do
      {:ok, project} ->
        preloads = [
          {:simulations, :simulation_id, :simulation, &%{simulation_ids: &1},
           RenewCollabSim.Queries.ListSimulations, RenewCollabSim.SimulationFetcher},
          {:shadow_net_systems, :shadow_net_system_id, :shadow_net_system,
           &%{shadow_net_system_ids: &1}, RenewCollabSim.Queries.ListShadowNetSystems,
           RenewCollabSim.SimulationFetcher},
          {:members, :account_id, :account, &%{account_ids: &1},
           RenewCollabAuth.Queries.AccountsWithIds, RenewCollabAuth.AuthFetcher},
          {:documents, :document_id, :document, &%{document_ids: &1},
           RenewCollab.Queries.DocumentList, RenewCollab.DocumentFetcher}
        ]

        for {coll, fk, assoc, attrs, cmd, fetcher} <- preloads, reduce: {:ok, project} do
          {:ok, proj} ->
            {:ok, entries} =
              Enum.map(Map.get(proj, coll), &Map.get(&1, fk))
              |> then(attrs)
              |> cmd.new()
              |> fetcher.fetch()

            entries_by_id =
              Map.new(entries, &{&1.id, &1})

            {:ok,
             proj
             |> Map.update(coll, [], fn assignments ->
               assignments
               |> Enum.map(fn asgn ->
                 case Map.fetch(entries_by_id, Map.get(asgn, fk)) do
                   {:ok, entry} ->
                     %{asgn | assoc => entry} |> Ecto.put_meta(state: :loaded)

                   :error ->
                     asgn
                 end
               end)
             end)}
        end
    end
  end

  def do_fetch(_account, %Views.GlobalAccounts{}) do
    RenewCollabAuth.Queries.AllAccounts.new(%{})
    |> RenewCollabAuth.AuthFetcher.fetch()
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

  def do_fetch(_account, %Views.GlobalSocketSchemasList{}) do
    RenewCollab.Queries.SocketSchemasList.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasMap{}) do
    RenewCollab.Queries.SocketSchemasList.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> case do
      {:ok, sockets} ->
        sockets
        |> Enum.map(&{&1.id, &1})
        |> Map.new()
        |> then(&{:ok, &1})
    end
  end

  def do_fetch(_account, %Views.GlobalSocketSchema{socket_schema_id: id}) do
    {:ok, RenewCollab.Sockets.find_socket_schema(id)}
  end

  def do_fetch(_account, %Views.GlobalSymbolsList{}) do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.DocumentFetcher.fetch()
  end

  def do_fetch(_account, %Views.GlobalSymbolsMap{}) do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> case do
      {:ok, symbols} ->
        symbols
        |> Enum.map(&{&1.id, &1})
        |> Map.new()
        |> then(&{:ok, &1})
    end
  end

  def do_fetch(_account, %Views.GlobalSymbol{symbol_id: id}) do
    RenewCollab.Symbols.find_symbol(id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalSyntaxList{}) do
    {:ok, RenewCollab.Syntax.find_all()}
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

  def do_fetch(_account, %Views.ProjectInvitations{project_id: project_id}) do
    %{project_id: project_id}
    |> RenewCollabProj.Queries.ProjectInvitations.new()
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.MediaData{media_id: media_id}) do
    Media.get_svg(media_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.MyProjectInvitations{account_id: account_id}) do
    %{account_id: account_id}
    |> RenewCollabProj.Queries.AccountProjectInvitations.new()
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
              %{member | account: account}

            :error ->
              # leave as-is if the post isn’t in the loaded list
              %{member | account: nil}
          end
        end)
        |> then(&{:ok, &1})
    end
  end

  def do_fetch(_account, %Views.ProjectDocumentsList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectDocumentIds.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, document_ids} ->
        %{document_ids: document_ids}
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

  def do_fetch(_account, %Views.ProjectRunningSimulationIds{project_id: project_id}) do
    RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id)
    |> MapSet.new()
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.SimulationIsActive{project_id: proj_id, simulation_id: sim_id}) do
    RenewCollabSim.Server.ScopedSimulationServer.exists(proj_id, sim_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.SimulationIsPlaying{project_id: proj_id, simulation_id: sim_id}) do
    RenewCollabSim.Server.ScopedSimulationServer.is_playing(proj_id, sim_id)
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.ProjectSimulationsList{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectSimulationIds.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, simulation_ids} ->
        %{simulation_ids: simulation_ids}
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

  def do_fetch(_account, %Views.ShadowNetSystemSimulations{shadow_net_system_id: sns_id}) do
    RenewCollabSim.Queries.ShadowNetSystemsSimulations.new(%{shadow_net_system_id: sns_id})
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.SimulationWithState{simulation_id: simulation_id}) do
    RenewCollabSim.Queries.Simulation.new(%{simulation_id: simulation_id, detailed: true})
    |> RenewCollabSim.SimulationFetcher.fetch()
    |> case do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, %{} = simulation} ->
        RenewCollabProj.Queries.SimulationsProject.new(%{simulation_id: simulation_id})
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
      simulation_active_count: RenewCollabSim.Server.ScopedSimulationServer.count_all(),
      formalisms: RenewCollabSim.Compiler.SnsCompiler.formalisms()
    }
    |> then(&{:ok, &1})
  end

  def do_fetch(_account, %Views.GlobalProjectAllAssignments{}) do
    RenewCollabProj.Queries.AllProjectAssignments.new(%{})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  def do_fetch(_account, %Views.SimulationWithLogEntries{simulation_id: simulation_id}) do
    RenewCollabSim.Queries.SimulationLogEntries.new(%{simulation_id: simulation_id})
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_acocunt, %Views.SimulationNetInstance{net_instance_id: net_instance_id}) do
    RenewCollabSim.Queries.SimulationNetInstanceById.new(%{net_instance_id: net_instance_id})
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_acocunt, %Views.SimulationNetInstanceByName{
        simulation_id: simulation_id,
        net_name: net_name,
        integer_id: integer_id
      }) do
    RenewCollabSim.Queries.SimulationNetInstanceByName.new(%{
      simulation_id: simulation_id,
      net_name: net_name,
      integer_id: integer_id
    })
    |> RenewCollabSim.SimulationFetcher.fetch()
  end

  def do_fetch(_account, %Views.MyRegistration{registration_id: registration_id}) do
    RenewCollabAuth.Queries.RegisrationById.new(%{registration_id: registration_id})
    |> RenewCollabAuth.AuthFetcher.fetch()
  end

  def do_fetch(_account, %Views.PendingPasswordResetRequest{reset_id: reset_id}) do
    RenewCollabAuth.Queries.PendingPasswordResetRequest.new(%{reset_id: reset_id})
    |> RenewCollabAuth.AuthFetcher.fetch()
  end
end
