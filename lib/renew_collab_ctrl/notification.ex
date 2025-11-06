defmodule RenewCollabCtrl.Notification do
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
    do: [{"pub-project-documents:#{proj_id}", :documents_changed}]

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
    do: [document_modified(doc_id), project_documents_modified(proj)]

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

  def notifications_for(proj, %Actions.DocumentDuplicateInProject{project_id: proj_id}, _result),
    do: [project_documents_modified(proj)]

  def notifications_for(_proj, %Actions.DocumentMoveIntoProject{project_id: proj_id}, _result),
    do: []

  def notifications_for(proj, %Actions.DocumentUpdateMeta{document_id: doc_id}, _result),
    do: [document_modified(doc_id), project_documents_modified(proj)]

  def notifications_for(_proj, %Actions.GlobalPrimitivesCreateDefinition{}, _result),
    do: [{"pub-global_primitives", :changed}]

  def notifications_for(_proj, %Actions.GlobalPrimitivesCreateGroup{}, _result),
    do: [{"pub-global_primitives", :changed}]

  def notifications_for(_proj, %Actions.GlobalPrimitivesDeleteDefinition{}, _result),
    do: [{"pub-global_primitives", :changed}]

  def notifications_for(_proj, %Actions.GlobalPrimitivesDeleteGroup{}, _result),
    do: [{"pub-global_primitives", :changed}]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaCreateSocket{}, _result),
    do: [{"pub-global_socket_schemas", :changed}]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaCreate{}, _result),
    do: [{"pub-global_socket_schemas", :changed}]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaDeleteSocket{}, _result),
    do: [{"pub-global_socket_schemas", :changed}]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaDelete{}, _result),
    do: [{"pub-global_socket_schemas", :changed}]

  def notifications_for(_proj, %Actions.GlobalSocketSchemaUpdate{}, _result),
    do: [{"pub-global_socket_schemas", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxAddAutoTargetEntry{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxAddWhitelistEntry{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxCreate{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxDeleteAutoTargetEntry{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxDeleteWhitelistEntry{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxDelete{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.GlobalSyntaxMakeDefault{}, _result),
    do: [{"pub-global_syntax", :changed}]

  def notifications_for(_proj, %Actions.ProjectAcceptInvitation{project_id: proj_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.ProjectAddDocumentAsAdmin{project_id: proj_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.ProjectAddMemberAsAdmin{project_id: proj_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.ProjectAddMemberAsUser{project_id: proj_id}, _result),
    do: []

  def notifications_for(
        _proj,
        %Actions.ProjectAddShadowNetSystemAsAdmin{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(
        _proj,
        %Actions.ProjectAddSimulationAsAdmin{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(_proj, %Actions.ProjectCreateAsAdmin{}, _result), do: []

  def notifications_for(_proj, %Actions.ProjectCreateAsUser{account_id: acc_id}, _result),
    do: [{"pub-my-projects:#{acc_id}", :projects_changed}]

  def notifications_for(proj, %Actions.ProjectDelete{project_id: proj_id}, _result),
    do: project_modified(proj)

  def notifications_for(proj, %Actions.ProjectDuplicateAsAdmin{}, _result),
    do: project_modified(proj)

  def notifications_for(proj, %Actions.ProjectDuplicateAsUser{project_id: project_id}, _result),
    do: project_modified(proj)

  def notifications_for(_proj, %Actions.ProjectInviteMember{project_id: proj_id}, _result), do: []
  def notifications_for(_proj, %Actions.ProjectMediaCreateSvg{}, _result), do: []
  def notifications_for(_proj, %Actions.ProjectMemberWithdraw{}), do: []
  def notifications_for(_proj, %Actions.ProjectRejectInvitation{}, _result), do: []

  def notifications_for(
        _proj,
        %Actions.ProjectRemoveDocumentAsAdmin{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(_proj, %Actions.ProjectRemoveMemberAsAdmin{project_id: proj_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.ProjectRemoveMemberAsUser{project_id: proj_id}, _result),
    do: []

  def notifications_for(
        _proj,
        %Actions.ProjectRemoveShadowNetSystemAsAdmin{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(
        _proj,
        %Actions.ProjectRemoveSimulationAsAdmin{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(proj, %Actions.ProjectRename{project_id: proj_id}, _result),
    do: project_modified(proj)

  def notifications_for(_proj, %Actions.ProjectRevokeInvitation{project_id: proj_id}, _result),
    do: []

  def notifications_for(
        _proj,
        %Actions.ShadowNetSystemCreateFromRnwInProject{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(_proj, %Actions.ShadowNetSystemDeleteAsUser{}, _result), do: []
  def notifications_for(_proj, %Actions.ShadowNetSystemDuplicateInProject{}, _result), do: []

  def notifications_for(_proj, %Actions.ShadowNetSystemImportFromSnsFileInProject{}, _result),
    do: []

  def notifications_for(_proj, %Actions.ShadowNetSystemRename{}, _result), do: []
  def notifications_for(_proj, %Actions.ShadowNetSystemSetMainNet{}, _result), do: []
  def notifications_for(_proj, %Actions.ShadowNetSystemSetNetDocument{}, _result), do: []

  def notifications_for(
        _proj,
        %Actions.SimulationCreateFromDocumentsInProject{project_id: proj_id},
        _result
      ),
      do: []

  def notifications_for(
        proj,
        %Actions.SimulationCreateFromShadowNetSystemInProject{project_id: proj_id},
        _result
      ),
      do: [project_simulations_modified(proj)]

  def notifications_for(proj, %Actions.SimulationDeleteAsUser{simulation_id: sim_id}, _result),
    do: [project_simulations_modified(proj)]

  def notifications_for(
        proj,
        %Actions.SimulationDuplicateInProject{project_id: proj_id},
        _result
      ),
      do: [project_simulations_modified(proj)]

  def notifications_for(_proj, %Actions.SimulationInitialize{simulation_id: sim_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.SimulationInstancesClear{simulation_id: sim_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.SimulationLogClear{simulation_id: sim_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.SimulationLogDebug{simulation_id: sim_id}, _result),
    do: []

  def notifications_for(_proj, %Actions.SimulationPause{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationPlay{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationRename{simulation_id: sim_id}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationReset{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationStep{}, _result), do: []
  def notifications_for(_proj, %Actions.SimulationTerminate{}, _result), do: []

  def notifications_for(_proj, _action, _result), do: []

  defp document_modified(doc_id), do: {"pub-document:#{doc_id}", {:document_modified, doc_id}}

  defp project_documents_modified(proj) do
    {"pub-project-documents:#{proj.id}", :documents_changed}
  end

  defp project_simulations_modified(proj) do
    {"pub-project-simulations:#{proj.id}", :simulations_changed}
  end

  defp project_modified(proj) do
    for %{account_id: acc_id} <-
          proj.members do
      {"pub-my-projects:#{acc_id}", :projects_changed}
    end
  end
end
