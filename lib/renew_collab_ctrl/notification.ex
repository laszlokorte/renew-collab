defmodule RenewCollabCtrl.Notification do
  alias RenewCollabProj.Entities.ProjectInvitation
  alias RenewCollabProj.Entities.ProjectMember
  alias RenewCollabCtrl.Actions

  def notifications_for(proj, action, result)

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerTextSizeHint{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditSetThumbnail{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditRemoveThumbnail{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentCreateInProject{project_id: proj_id}, _result),
    do: [project_documents_modified(proj_id)]

  def notifications_for(_proj, %Actions.DocumentEditCreateLayer{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditCreateLayerWithEdge{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditImportFile{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(proj, %Actions.DocumentDeleteAsUser{document_id: doc_id}, _result),
    do: [document_modified(doc_id), project_documents_modified(proj.id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditSetLayerVisibility{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditCreateParentLayer{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditMakeSpaceBetween{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditDeleteBond{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerStyle{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerEdgeStyle{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerTextStyle{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerTextBody{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerBoxSize{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerTextPosition{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerEdgePosition{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerEdgeSwapDirection{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerEdgeWaypointPosition{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditDeleteEdgeWaypoint{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditCreateEdgeWaypoint{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditEdgeRemoveAllWaypoints{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerSemanticTag{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLayerBoxShape{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditReorderLayer{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditMoveLayerRelative{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditDeleteLayer{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditPasteLayers{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditCreateEdgeBond{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditUnlinkLayer{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditLinkLayer{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditLayerAssignSocketSchema{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditRemoveLayerSocketSchema{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentEditCreateSnapshot{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentSnapshotRestore{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditSnapshotCreateLabel{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditSnapshotRemoveLabel{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditInsertDocument{target_document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(
        _proj,
        %Actions.DocumentEditReorderLayerRelative{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentSnapshotsPrune{document_id: doc_id}, _result),
    do: [document_modified(doc_id)]

  def notifications_for(_proj, %Actions.DocumentDuplicateInProject{project_id: proj_id}, _result),
    do: [project_documents_modified(proj_id)]

  def notifications_for(proj, %Actions.DocumentMoveIntoProject{}, _result),
    do: [project_documents_modified(proj) | project_modified(proj)]

  def notifications_for(proj, %Actions.DocumentUpdateMeta{document_id: doc_id}, _result),
    do: [document_modified(doc_id), project_documents_modified(proj.id)]

  def notifications_for(_proj, %Actions.GlobalPrimitivesCreateDefinition{}, _result),
    do: [global_primitive_changed()]

  def notifications_for(_proj, %Actions.GlobalPrimitivesCreateGroup{}, _result),
    do: [global_primitive_changed()]

  def notifications_for(_proj, %Actions.GlobalPrimitivesDeleteDefinition{}, _result),
    do: [global_primitive_changed()]

  def notifications_for(_proj, %Actions.GlobalPrimitivesDeleteGroup{}, _result),
    do: [global_primitive_changed()]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaCreateSocket{}, _result),
    do: [global_socket_schema_changed()]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaCreate{}, _result),
    do: [global_socket_schema_changed()]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaDeleteSocket{}, _result),
    do: [global_socket_schema_changed()]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaDelete{}, _result),
    do: [global_socket_schema_changed()]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaUpdate{}, _result),
    do: [global_socket_schema_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxAddAutoTargetEntry{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxAddWhitelistEntry{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxCreate{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxDeleteAutoTargetEntry{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxDeleteWhitelistEntry{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxDelete{}, _result),
    do: [syntax_changed()]

  def notifications_for(_proj, %Actions.GlobalSyntaxMakeDefault{}, _result),
    do: [syntax_changed()]

  def notifications_for(
        proj,
        %Actions.ProjectAcceptInvitation{},
        %ProjectMember{account_id: acc_id}
      ),
      do:
        [
          own_projects_modified(acc_id) | project_modified(proj)
        ]
        |> Enum.concat(invitations_changed(proj, acc_id))

  def notifications_for(
        proj,
        %Actions.ProjectAddDocumentAsAdmin{},
        _res
      ),
      do: project_documents_modified(proj)

  def notifications_for(
        proj,
        %Actions.ProjectAddMemberAsAdmin{account_id: acc_id},
        _re
      ),
      do: [own_projects_modified(acc_id) | project_modified(proj)]

  def notifications_for(
        proj,
        %Actions.ProjectAddShadowNetSystemAsAdmin{},
        _result
      ),
      do: [project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.ProjectAddSimulationAsAdmin{},
        _result
      ),
      do: [project_simulations_modified(proj.id)]

  def notifications_for(_proj, %Actions.ProjectCreateAsAdmin{}, _result),
    do: [{"pub-global-projects", :projects_changed}]

  def notifications_for(_proj, %Actions.ProjectCreateAsUser{account_id: acc_id}, _result),
    do: [own_projects_modified(acc_id)]

  def notifications_for(proj, %Actions.ProjectDelete{}, _result),
    do: project_modified(proj)

  def notifications_for(proj, %Actions.ProjectDuplicateAsAdmin{}, _result),
    do: project_modified(proj)

  def notifications_for(
        proj,
        %Actions.ProjectDuplicateAsUser{account_id: acc_id},
        _result
      ),
      do: [own_projects_modified(acc_id) | project_modified(proj)]

  def notifications_for(
        proj,
        %Actions.ProjectInviteMember{},
        %ProjectInvitation{account_id: acc_id}
      ),
      do: invitations_changed(proj, acc_id)

  def notifications_for(_proj, %Actions.ProjectMediaCreateSvg{}, _result), do: []

  def notifications_for(proj, %Actions.ProjectMemberWithdraw{account_id: acc_id}, _result),
    do: [own_projects_modified(acc_id) | project_modified(proj)]

  def notifications_for(proj, %Actions.ProjectRejectInvitation{account_id: acc_id}, _result),
    do: invitations_changed(proj, acc_id)

  def notifications_for(
        proj,
        %Actions.ProjectRemoveDocumentAsAdmin{document_id: doc_id},
        _result
      ),
      do: [document_modified(doc_id), project_documents_modified(proj)]

  def notifications_for(proj, %Actions.ProjectRemoveMemberAsAdmin{}, _result),
    do: project_modified(proj)

  def notifications_for(proj, %Actions.ProjectRemoveMemberAsUser{}, _result),
    do: project_modified(proj)

  def notifications_for(
        proj,
        %Actions.ProjectRemoveShadowNetSystemAsAdmin{},
        _result
      ),
      do: project_shadow_net_systems_modified(proj.id)

  def notifications_for(
        proj,
        %Actions.ProjectRemoveSimulationAsAdmin{simulation_id: sim_id},
        _result
      ),
      do: [simulation_modified(sim_id), project_simulations_modified(proj.id)]

  def notifications_for(proj, %Actions.ProjectRename{}, _result),
    do: project_modified(proj)

  def notifications_for(
        proj,
        %Actions.ProjectRevokeInvitation{},
        %ProjectInvitation{account_id: account_id}
      ),
      do: invitations_changed(proj, account_id)

  def notifications_for(
        proj,
        %Actions.ShadowNetSystemCreateFromRnwInProject{},
        _result
      ),
      do: [project_shadow_net_systems_modified(proj.id)]

  def notifications_for(proj, %Actions.ShadowNetSystemDeleteAsUser{}, _result),
    do: [project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        _proj,
        %Actions.ShadowNetSystemDuplicateInProject{project_id: proj_id},
        _result
      ),
      do: [project_shadow_net_systems_modified(proj_id)]

  def notifications_for(proj, %Actions.ShadowNetSystemImportFromSnsFileInProject{}, _result),
    do: [project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.ShadowNetSystemRename{shadow_net_system_id: sns_id},
        _result
      ),
      do: [shadow_net_system_modified(sns_id), project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.ShadowNetSystemSetMainNet{shadow_net_system_id: sns_id},
        _result
      ),
      do: [shadow_net_system_modified(sns_id), project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.ShadowNetSystemSetNetDocument{shadow_net_system_id: sns_id},
        _result
      ),
      do: [shadow_net_system_modified(sns_id), project_shadow_net_systems_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.SimulationCreateFromDocumentsInProject{},
        _result
      ),
      do: [project_simulations_modified(proj.id)]

  def notifications_for(
        proj,
        %Actions.SimulationCreateFromShadowNetSystemInProject{shadow_net_system_id: sns_id},
        _result
      ),
      do: [project_simulations_modified(proj.id), shadow_net_system_modified(sns_id)]

  def notifications_for(proj, %Actions.SimulationDeleteAsUser{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id), project_simulations_modified(proj.id)]

  def notifications_for(proj, %Actions.SimulationDuplicateInProject{}, _result),
    do: [project_simulations_modified(proj.id)]

  def notifications_for(_proj, %Actions.SimulationInitialize{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id)]

  def notifications_for(_proj, %Actions.SimulationInstancesClear{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id)]

  def notifications_for(_proj, %Actions.SimulationLogClear{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id)]

  def notifications_for(_proj, %Actions.SimulationLogDebug{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id)]

  def notifications_for(proj, %Actions.SimulationRename{simulation_id: sim_id}, _result),
    do: [simulation_modified(sim_id), project_simulations_modified(proj.id)]

  def notifications_for(_proj, %Actions.SimulationPause{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationPlay{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationReset{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationStep{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationTerminate{}, _result), do: []

  def notifications_for(_proj, _action, _result), do: []

  defp document_modified(doc_id), do: {"pub-document:#{doc_id}", {:document_modified, doc_id}}

  defp simulation_modified(sim_id),
    do: {"simulation:#{sim_id}", {:simulation_change, sim_id}}

  defp shadow_net_system_modified(sns_id),
    do: {"pub-shadow-net-system:#{sns_id}", {:shadow_net_system_modified, sns_id}}

  defp project_documents_modified(proj_id) do
    {"pub-project-documents:#{proj_id}", :documents_changed}
  end

  defp project_simulations_modified(proj_id) do
    {"pub-project-simulations:#{proj_id}", :simulations_changed}
  end

  defp project_shadow_net_systems_modified(proj_id) do
    {"pub-project-shadow-net-systems:#{proj_id}", :shadow_net_systems_changed}
  end

  defp own_projects_modified(acc_id), do: {"pub-my-projects:#{acc_id}", :projects_changed}

  defp project_modified(proj) do
    [
      {"pub-project:#{proj.id}", :project_changed}
      | for %{account_id: acc_id} <-
              proj.members do
          {"pub-my-projects:#{acc_id}", :projects_changed}
        end
    ]
  end

  defp syntax_changed(), do: {"pub-global_syntax", :syntax_changed}

  defp invitations_changed(proj, account_id),
    do: [
      {"pub-my-invitations:#{account_id}", :invitations_changed},
      {"pub-project:#{proj.id}", :invitations_changed}
      | project_modified(proj)
    ]

  defp global_primitive_changed(), do: {"pub-global_primitives", :primitives_changed}
  defp global_socket_schema_changed(), do: {"pub-global_socket_schemas", :socket_schema_changed}
end
