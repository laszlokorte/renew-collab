defmodule RenewCollabCtrl.Action do
  alias RenewCollabCtrl.Actions

  def do_perform(%Actions.AccountChangePasswordAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.AccountChangePasswordAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.AccountCreateAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.AccountCreateAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.AccountDeleteAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.AccountDeleteAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentCreateInProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentDeleteAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentDuplicateInProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateEdgeBond{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateEdgeWaypoint{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateLayerWithEdge{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateParentLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditDeleteBond{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditDeleteEdgeWaypoint{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditDeleteLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditEdgeRemoveAllWaypoints{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditInsertDocument{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerAssignSocketSchema{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerBoxShape{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerBoxSize{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerEdgeAttributes{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerEdgePosition{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerEdgeStyle{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerEdgeSwapDirection{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerEdgeWaypointPosition{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerSemanticTag{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerStyle{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerTextBody{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerTextPosition{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerTextSizeHint{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerTextStyle{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLayerZIndex{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditLinkLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditMakeSpaceBetween{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditMoveLayerRelative{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditRemoveLayerSocketSchema{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditReorderLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditReorderLayerRelative{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditSetLayerVisibility{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditUnlinkLayer{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentMoveIntoProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentRename{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentSnapshotRestore{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentSnapshotsPrune{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectAddDocumentAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectAddMemberAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectAddMemberAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectAddSimulationAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectAddSsnAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectCreateAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectCreateAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectDelete{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectDuplicateAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectDuplicateAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectRemoveDocumentAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectRemoveMemberAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectRemoveSimulationAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectRemoveSsnAsAdmin{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ProjectRename{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ShadowNetSystemCreateFromRnwInProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ShadowNetSystemDeleteAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ShadowNetSystemDuplicateInProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ShadowNetSystemImportIntoProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.ShadowNetSystemRename{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationDeleteAsUser{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationInitialize{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationClear{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationLogClear{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationLogDebug{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationPause{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationPlay{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationRename{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationStep{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationTerminate{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SystemReinstall{}) do
    :ok
  end
end
