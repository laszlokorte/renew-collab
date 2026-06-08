defmodule RenewCollabCtrl.CacheConfig do
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Actions

  @static_resource_ttl 300

  def key_for_view(account, view)
  def key_for_view(_account, %Views.DocumentLayerRelative{}), do: nil
  def key_for_view(_account, %Views.DocumentLayerHyperlinked{}), do: nil
  def key_for_view(_account, %Views.DocumentLayerGraphConnection{}), do: nil
  def key_for_view(_account, %Views.DocumentLayerRelativeMultiple{}), do: nil
  def key_for_view(_account, %Views.DocumentLayerConnectedComponent{}), do: nil
  def key_for_view(_account, %Views.DocumentStripped{}), do: nil
  def key_for_view(_account, %Views.DocumentVersionState{}), do: nil
  def key_for_view(_account, %Views.DocumentVersionsList{}), do: nil
  def key_for_view(_account, %Views.DocumentWithContent{}), do: nil
  def key_for_view(_account, %Views.GlobalAccounts{}), do: nil
  def key_for_view(_account, %Views.GlobalDocumentsList{}), do: nil
  def key_for_view(_account, %Views.GlobalPrimitives{}), do: {:global, :primitives}
  def key_for_view(_account, %Views.GlobalShadowNetSystemsList{}), do: nil
  def key_for_view(_account, %Views.GlobalSimulationsList{}), do: nil
  def key_for_view(_account, %Views.GlobalSocketById{}), do: nil
  def key_for_view(_account, %Views.GlobalSocketSchemasList{}), do: {:global, :socket_schemas}
  def key_for_view(_account, %Views.GlobalSocketSchemasMap{}), do: {:global, :socket_schemas_map}
  def key_for_view(_account, %Views.GlobalSymbolsList{}), do: {:global, :symbols}
  def key_for_view(_account, %Views.GlobalSyntaxList{}), do: {:global, :syntax}
  def key_for_view(_account, %Views.MyProjectsList{}), do: nil
  def key_for_view(_account, %Views.ProjectDocumentsList{}), do: nil
  def key_for_view(_account, %Views.ProjectShadowNetSystemsList{}), do: nil
  def key_for_view(_account, %Views.ProjectSimulationsList{}), do: nil
  def key_for_view(_account, %Views.ShadowNetSystemSimulations{}), do: nil
  def key_for_view(_account, %Views.SimulationWithState{}), do: nil
  def key_for_view(_, _), do: nil

  def tags_for_view(account, view)
  def tags_for_view(_account, %Views.DocumentLayerRelative{}), do: []
  def tags_for_view(_account, %Views.DocumentLayerHyperlinked{}), do: []
  def tags_for_view(_account, %Views.DocumentLayerGraphConnection{}), do: []
  def tags_for_view(_account, %Views.DocumentLayerRelativeMultiple{}), do: []
  def tags_for_view(_account, %Views.DocumentLayerConnectedComponent{}), do: []
  def tags_for_view(_account, %Views.DocumentStripped{}), do: []
  def tags_for_view(_account, %Views.DocumentVersionState{}), do: []
  def tags_for_view(_account, %Views.DocumentVersionsList{}), do: []
  def tags_for_view(_account, %Views.DocumentWithContent{}), do: []
  def tags_for_view(_account, %Views.GlobalAccounts{}), do: []
  def tags_for_view(_account, %Views.GlobalDocumentsList{}), do: []
  def tags_for_view(_account, %Views.GlobalPrimitives{}), do: []
  def tags_for_view(_account, %Views.GlobalShadowNetSystemsList{}), do: []
  def tags_for_view(_account, %Views.GlobalSimulationsList{}), do: []
  def tags_for_view(_account, %Views.GlobalSocketById{}), do: []
  def tags_for_view(_account, %Views.GlobalSocketSchemasList{}), do: []
  def tags_for_view(_account, %Views.GlobalSocketSchemasMap{}), do: []
  def tags_for_view(_account, %Views.GlobalSymbolsList{}), do: []
  def tags_for_view(_account, %Views.GlobalSyntaxList{}), do: []
  def tags_for_view(_account, %Views.MyProjectsList{}), do: []
  def tags_for_view(_account, %Views.ProjectDocumentsList{}), do: []
  def tags_for_view(_account, %Views.ProjectShadowNetSystemsList{}), do: []
  def tags_for_view(_account, %Views.ProjectSimulationsList{}), do: []
  def tags_for_view(_account, %Views.ShadowNetSystemSimulations{}), do: []
  def tags_for_view(_account, %Views.SimulationWithState{}), do: []
  def tags_for_view(_, _), do: nil

  def ttl_for_view(view)
  def ttl_for_view(%Views.DocumentLayerRelative{}), do: :infinity
  def ttl_for_view(%Views.DocumentLayerHyperlinked{}), do: :infinity
  def ttl_for_view(%Views.DocumentLayerGraphConnection{}), do: :infinity
  def ttl_for_view(%Views.DocumentLayerRelativeMultiple{}), do: :infinity
  def ttl_for_view(%Views.DocumentLayerConnectedComponent{}), do: :infinity
  def ttl_for_view(%Views.DocumentStripped{}), do: :infinity
  def ttl_for_view(%Views.DocumentVersionState{}), do: :infinity
  def ttl_for_view(%Views.DocumentVersionsList{}), do: :infinity
  def ttl_for_view(%Views.DocumentWithContent{}), do: :infinity
  def ttl_for_view(%Views.GlobalAccounts{}), do: :infinity
  def ttl_for_view(%Views.GlobalDocumentsList{}), do: :infinity
  def ttl_for_view(%Views.GlobalPrimitives{}), do: @static_resource_ttl
  def ttl_for_view(%Views.GlobalShadowNetSystemsList{}), do: :infinity
  def ttl_for_view(%Views.GlobalSimulationsList{}), do: :infinity
  def ttl_for_view(%Views.GlobalSocketById{}), do: :infinity
  def ttl_for_view(%Views.GlobalSocketSchemasList{}), do: @static_resource_ttl
  def ttl_for_view(%Views.GlobalSocketSchemasMap{}), do: @static_resource_ttl
  def ttl_for_view(%Views.GlobalSymbolsList{}), do: @static_resource_ttl
  def ttl_for_view(%Views.GlobalSyntaxList{}), do: @static_resource_ttl
  def ttl_for_view(%Views.MyProjectsList{}), do: :infinity
  def ttl_for_view(%Views.ProjectDocumentsList{}), do: :infinity
  def ttl_for_view(%Views.ProjectShadowNetSystemsList{}), do: :infinity
  def ttl_for_view(%Views.ProjectSimulationsList{}), do: :infinity
  def ttl_for_view(%Views.ShadowNetSystemSimulations{}), do: :infinity
  def ttl_for_view(%Views.SimulationWithState{}), do: :infinity
  def ttl_for_view(_), do: nil

  def tags_for_action(%Actions.AccountSetAdmin{}, _result), do: []
  def tags_for_action(%Actions.AccountChangePasswordAsUser{}, _result), do: []
  def tags_for_action(%Actions.AccountCreateAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.AccountDeleteAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.AccountDeleteAsUser{}, _result), do: []
  def tags_for_action(%Actions.DocumentCreateInProject{}, _result), do: []
  def tags_for_action(%Actions.DocumentDeleteAsUser{}, _result), do: []
  def tags_for_action(%Actions.DocumentDuplicateInProject{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditCreateEdgeBond{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditCreateEdgeWaypoint{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditCreateLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditCreateLayerWithEdge{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditCreateParentLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditDeleteBond{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditDeleteEdgeWaypoint{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditDeleteLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditEdgeRemoveAllWaypoints{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditInsertDocument{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerAssignSocketSchema{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerBoxShape{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerBoxSize{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerEdgeAttributes{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerEdgePosition{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerEdgeStyle{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerEdgeSwapDirection{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerEdgeWaypointPosition{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerSemanticTag{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerStyle{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerTextBody{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerTextPosition{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerTextSizeHint{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerTextStyle{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLayerZIndex{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditLinkLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditMakeSpaceBetween{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditMoveLayerRelative{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditRemoveLayerSocketSchema{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditReorderLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditReorderLayerRelative{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditSetLayerVisibility{}, _result), do: []
  def tags_for_action(%Actions.DocumentEditUnlinkLayer{}, _result), do: []
  def tags_for_action(%Actions.DocumentMoveIntoProject{}, _result), do: []
  def tags_for_action(%Actions.DocumentRename{}, _result), do: []
  def tags_for_action(%Actions.DocumentSnapshotRestore{}, _result), do: []
  def tags_for_action(%Actions.DocumentSnapshotsPrune{}, _result), do: []
  def tags_for_action(%Actions.ProjectAddDocumentAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectAddMemberAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectAddSimulationAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectAddShadowNetSystemAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectCreateAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectCreateAsUser{}, _result), do: []
  def tags_for_action(%Actions.ProjectDelete{}, _result), do: []
  def tags_for_action(%Actions.ProjectDuplicateAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectDuplicateAsUser{}, _result), do: []
  def tags_for_action(%Actions.ProjectRemoveDocumentAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectRemoveMemberAsUser{}, _result), do: []
  def tags_for_action(%Actions.ProjectRemoveSimulationAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectRemoveShadowNetSystemAsAdmin{}, _result), do: []
  def tags_for_action(%Actions.ProjectRename{}, _result), do: []
  def tags_for_action(%Actions.ShadowNetSystemCreateFromRnwInProject{}, _result), do: []
  def tags_for_action(%Actions.ShadowNetSystemDeleteAsUser{}, _result), do: []
  def tags_for_action(%Actions.ShadowNetSystemDuplicateInProject{}, _result), do: []
  def tags_for_action(%Actions.ShadowNetSystemRename{}, _result), do: []
  def tags_for_action(%Actions.SimulationDeleteAsUser{}, _result), do: []
  def tags_for_action(%Actions.SimulationInitialize{}, _result), do: []
  def tags_for_action(%Actions.SimulationInstancesClear{}, _result), do: []
  def tags_for_action(%Actions.SimulationLogClear{}, _result), do: []
  def tags_for_action(%Actions.SimulationLogDebug{}, _result), do: []
  def tags_for_action(%Actions.SimulationPause{}, _result), do: []
  def tags_for_action(%Actions.SimulationPlay{}, _result), do: []
  def tags_for_action(%Actions.SimulationRename{}, _result), do: []
  def tags_for_action(%Actions.SimulationStep{}, _result), do: []
  def tags_for_action(%Actions.SimulationTerminate{}, _result), do: []
  def tags_for_action(%Actions.SystemReinstall{}, _result), do: []
  def tags_for_action(_, _result), do: []
end
