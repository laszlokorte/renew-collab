defmodule RenewCollabCtrl.WriteAccess do
  alias RenewCollabCtrl.Actions
  def can(account, action)
  def can(_account, %Actions.ProjectDuplicateAsUser{}), do: true
  def can(_account, %Actions.ProjectDuplicateAsAdmin{}), do: true
  def can(_account, %Actions.ProjectAddMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRemoveMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectDelete{}), do: true
  def can(_account, %Actions.DocumentEditLayerTextSizeHint{}), do: true
  def can(_account, %Actions.DocumentEditSetThumbnail{}), do: true
  def can(_account, %Actions.DocumentEditRemoveThumbnail{}), do: true
  def can(_account, %Actions.DocumentCreateInProject{}), do: true
  def can(_account, %Actions.DocumentEditCreateLayer{}), do: true
  def can(_account, %Actions.DocumentSnapshotRestore{}), do: true
  def can(_account, %Actions.DocumentDuplicateInProject{}), do: true
  def can(_account, %Actions.DocumentEditLayerAssignSocketSchema{}), do: true
  def can(_account, %Actions.DocumentEditImportFile{}), do: true
  def can(_account, %Actions.DocumentDeleteAsUser{}), do: true

  def can(_account, %Actions.DocumentEditSetLayerVisibility{}), do: true

  def can(_account, %Actions.DocumentEditMakeSpaceBetween{}), do: true

  def can(_account, %Actions.DocumentEditDeleteBond{}), do: true

  def can(_account, %Actions.DocumentEditLayerStyle{}), do: true

  def can(_account, %Actions.DocumentEditLayerEdgeStyle{}), do: true

  def can(_account, %Actions.DocumentEditLayerTextStyle{}), do: true

  def can(_account, %Actions.DocumentEditLayerTextBody{}), do: true

  def can(_account, %Actions.DocumentEditLayerBoxSize{}), do: true

  def can(_account, %Actions.DocumentEditLayerTextPosition{}), do: true

  def can(_account, %Actions.DocumentEditLayerEdgePosition{}), do: true

  def can(_account, %Actions.DocumentEditLayerEdgeSwapDirection{}), do: true

  def can(_account, %Actions.DocumentEditLayerEdgeWaypointPosition{}), do: true

  def can(_account, %Actions.DocumentEditDeleteEdgeWaypoint{}), do: true

  def can(_account, %Actions.DocumentEditCreateEdgeWaypoint{}), do: true

  def can(_account, %Actions.DocumentEditEdgeRemoveAllWaypoints{}), do: true

  def can(_account, %Actions.DocumentEditLayerSemanticTag{}), do: true

  def can(_account, %Actions.DocumentEditLayerBoxShape{}), do: true

  def can(_account, %Actions.DocumentEditReorderLayer{}), do: true

  def can(_account, %Actions.DocumentEditMoveLayerRelative{}), do: true

  def can(_account, %Actions.DocumentEditDeleteLayer{}), do: true

  def can(_account, %Actions.DocumentEditCreateEdgeBond{}), do: true

  def can(_account, %Actions.DocumentEditUnlinkLayer{}), do: true

  def can(_account, %Actions.DocumentEditLinkLayer{}), do: true

  def can(_account, %Actions.DocumentEditLayerAssignSocketSchema{}), do: true

  def can(_account, %Actions.DocumentEditRemoveLayerSocketSchema{}), do: true

  def can(_account, %Actions.DocumentEditCreateSnapshot{}), do: true

  def can(_account, %Actions.DocumentSnapshotRestore{}), do: true

  def can(_account, %Actions.DocumentEditSnapshotCreateLabel{}), do: true

  def can(_account, %Actions.DocumentEditSnapshotRemoveLabel{}), do: true

  def can(_account, %Actions.DocumentSnapshotsPrune{}), do: true

  def can(_account, %Actions.DocumentUpdateMeta{}), do: true

  def can(_account, %Actions.DocumentEditInsertDocument{}), do: true

  def can(_account, %Actions.DocumentEditReorderLayerRelative{}), do: true

  def can(_account, %Actions.GlobalPrimitivesCreateGroup{}), do: true
  def can(_account, %Actions.GlobalPrimitivesDeleteGroup{}), do: true
  def can(_account, %Actions.GlobalPrimitivesDeleteDefinition{}), do: true
  def can(_account, %Actions.GlobalPrimitivesCreateDefinition{}), do: true

  def can(_account, %Actions.GlobalSocketSchemaDeleteSocket{}), do: true
  def can(_account, %Actions.GlobalSocketSchemaCreateSocket{}), do: true
  def can(_account, %Actions.GlobalSocketSchemaCreate{}), do: true
  def can(_account, %Actions.GlobalSocketSchemaDelete{}), do: true
  def can(_account, %Actions.GlobalSocketSchemaUpdate{}), do: true

  def can(_account, %Actions.GlobalSyntaxCreate{}), do: true
  def can(_account, %Actions.GlobalSyntaxDelete{}), do: true
  def can(_account, %Actions.GlobalSyntaxDeleteWhitelistEntry{}), do: true
  def can(_account, %Actions.GlobalSyntaxDeleteAutoTargetEntry{}), do: true
  def can(_account, %Actions.GlobalSyntaxMakeDefault{}), do: true
  def can(_account, %Actions.GlobalSyntaxAddWhitelistEntry{}), do: true
  def can(_account, %Actions.GlobalSyntaxAddAutoTargetEntry{}), do: true
  def can(%{id: account_id}, %Actions.ProjectCreateAsUser{account_id: account_id}), do: true
  def can(_account, %Actions.ProjectCreateAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRename{}), do: true

  def can(_account, %Actions.ProjectRemoveMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectAddMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectDelete{}), do: true
  def can(_account, %Actions.ProjectAddMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRemoveMemberAsAdmin{}), do: true
  def can(_account, %Actions.ProjectAddDocumentAsAdmin{}), do: true
  def can(_account, %Actions.DocumentDuplicateInProject{}), do: true
  def can(_account, %Actions.ProjectRemoveDocumentAsAdmin{}), do: true
  def can(_account, %Actions.ProjectAddSimulationAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRemoveSimulationAsAdmin{}), do: true
  def can(_account, %Actions.ProjectAddShadowNetSystemAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRemoveShadowNetSystemAsAdmin{}), do: true
  def can(_account, %Actions.ProjectRename{}), do: true
  def can(_account, %Actions.ProjectDelete{}), do: true

  def can(_account, _action), do: false
end
