defmodule RenewCollabCtrl.Notification do
  alias RenewCollabCtrl.Actions

  def notifications_for(action, result)

  def notifications_for(%Actions.DocumentEditLayerTextSizeHint{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditSetThumbnail{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditRemoveThumbnail{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentCreateInProject{}, _result), do: []

  def notifications_for(%Actions.DocumentEditCreateLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditCreateLayerWithEdge{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditImportFile{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentDeleteAsUser{}, _result), do: []

  def notifications_for(%Actions.DocumentEditSetLayerVisibility{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditCreateParentLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditMakeSpaceBetween{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditDeleteBond{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerStyle{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerEdgeStyle{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerTextStyle{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerTextBody{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerBoxSize{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerTextPosition{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerEdgePosition{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(
        %Actions.DocumentEditLayerEdgeSwapDirection{document_id: doc_id},
        _result
      ),
      do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(
        %Actions.DocumentEditLayerEdgeWaypointPosition{document_id: doc_id},
        _result
      ),
      do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditDeleteEdgeWaypoint{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditCreateEdgeWaypoint{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(
        %Actions.DocumentEditEdgeRemoveAllWaypoints{document_id: doc_id},
        _result
      ),
      do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerSemanticTag{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLayerBoxShape{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditReorderLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditMoveLayerRelative{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditDeleteLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditCreateEdgeBond{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditUnlinkLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditLinkLayer{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(
        %Actions.DocumentEditLayerAssignSocketSchema{document_id: doc_id},
        _result
      ),
      do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(
        %Actions.DocumentEditRemoveLayerSocketSchema{document_id: doc_id},
        _result
      ),
      do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditCreateSnapshot{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentSnapshotRestore{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditSnapshotCreateLabel{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditSnapshotRemoveLabel{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditInsertDocument{target_document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentEditReorderLayerRelative{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.DocumentSnapshotsPrune{document_id: doc_id}, _result),
    do: [{"document:#{doc_id}", {:document_modified, doc_id}}]

  def notifications_for(%Actions.ProjectDuplicateAsUser{project_id: project_id}, _result), do: []
  def notifications_for(%Actions.ProjectDuplicateAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectAddMemberAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectRemoveMemberAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectDelete{}, _result), do: []

  def notifications_for(%Actions.ShadowNetSystemImportFromSnsFileInProject{}, _result), do: []
  def notifications_for(%Actions.ShadowNetSystemCreateFromRnwInProject{}, _result), do: []
  def notifications_for(%Actions.SimulationCreateFromDocumentsInProject{}, _result), do: []
  def notifications_for(%Actions.SimulationCreateFromShadowNetSystemInProject{}, _result), do: []
  def notifications_for(%Actions.SimulationDeleteAsUser{}, _result), do: []
  def notifications_for(%Actions.SimulationRename{}, _result), do: []
  def notifications_for(%Actions.DocumentUpdateMeta{}, _result), do: []
  def notifications_for(%Actions.GlobalPrimitivesCreateGroup{}, _result), do: []
  def notifications_for(%Actions.GlobalPrimitivesDeleteGroup{}, _result), do: []
  def notifications_for(%Actions.GlobalPrimitivesDeleteDefinition{}, _result), do: []
  def notifications_for(%Actions.GlobalPrimitivesCreateDefinition{}, _result), do: []

  def notifications_for(%Actions.ShadowNetSystemDeleteAsUser{}, _result), do: []

  def notifications_for(%Actions.ShadowNetSystemRename{}, _result), do: []
  def notifications_for(%Actions.GlobalSocketSchemaDeleteSocket{}, _result), do: []
  def notifications_for(%Actions.GlobalSocketSchemaCreateSocket{}, _result), do: []
  def notifications_for(%Actions.GlobalSocketSchemaCreate{}, _result), do: []
  def notifications_for(%Actions.GlobalSocketSchemaDelete{}, _result), do: []
  def notifications_for(%Actions.GlobalSocketSchemaUpdate{}, _result), do: []

  def notifications_for(%Actions.GlobalSyntaxCreate{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxDelete{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxDeleteWhitelistEntry{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxDeleteAutoTargetEntry{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxMakeDefault{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxAddWhitelistEntry{}, _result), do: []
  def notifications_for(%Actions.GlobalSyntaxAddAutoTargetEntry{}, _result), do: []
  def notifications_for(%Actions.ProjectCreateAsUser{}, _result), do: []
  def notifications_for(%Actions.ProjectCreateAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectRename{}, _result), do: []

  def notifications_for(%Actions.DocumentDuplicateInProject{}, _result), do: []
  def notifications_for(%Actions.SimulationDuplicateInProject{}, _result), do: []
  def notifications_for(%Actions.ShadowNetSystemDuplicateInProject{}, _result), do: []
  def notifications_for(%Actions.ProjectAddDocumentAsAdmin{}, _result), do: []
  def notifications_for(%Actions.DocumentDuplicateInProject{}, _result), do: []
  def notifications_for(%Actions.ProjectRemoveDocumentAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectAddSimulationAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectRemoveSimulationAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectAddShadowNetSystemAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectRemoveShadowNetSystemAsAdmin{}, _result), do: []
  def notifications_for(%Actions.ProjectRemoveMemberAsUser{}, _result), do: []
  def notifications_for(%Actions.ProjectAddMemberAsUser{}, _result), do: []
  def notifications_for(%Actions.ProjectInviteMember{}, _result), do: []
  def notifications_for(%Actions.ProjectRevokeInvitation{}, _result), do: []
  def notifications_for(%Actions.ProjectRejectInvitation{}, _result), do: []
  def notifications_for(%Actions.ProjectAcceptInvitation{}, _result), do: []
  def notifications_for(%Actions.ProjectMemberWithdraw{}, _result), do: []
  def notifications_for(%Actions.ProjectMemberWithdraw{}), do: []

  def notifications_for(%Actions.SimulationLogDebug{}, _result), do: []
  def notifications_for(%Actions.SimulationPause{}, _result), do: []
  def notifications_for(%Actions.SimulationInitialize{}, _result), do: []
  def notifications_for(%Actions.SimulationInstancesClear{}, _result), do: []
  def notifications_for(%Actions.SimulationLogClear{}, _result), do: []
  def notifications_for(%Actions.SimulationPlay{}, _result), do: []
  def notifications_for(%Actions.SimulationStep{}, _result), do: []
  def notifications_for(%Actions.SimulationTerminate{}, _result), do: []
  def notifications_for(%Actions.SimulationReset{}, _result), do: []
  def notifications_for(%Actions.ShadowNetSystemSetNetDocument{}, _result), do: []
  def notifications_for(%Actions.ShadowNetSystemSetMainNet{}, _result), do: []
  def notifications_for(%Actions.ProjectMediaCreateSvg{}, _result), do: []
  def notifications_for(%Actions.DocumentMoveIntoProject{}, _result), do: []

  def notifications_for(_action, _result), do: []
end
