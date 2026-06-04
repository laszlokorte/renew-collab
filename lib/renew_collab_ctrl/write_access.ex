defmodule RenewCollabCtrl.WriteAccess do
  alias RenewCollabCtrl.ReadAccess
  alias RenewCollabCtrl.Actions
  def can(account, action)

  def can(%{id: _}, %Actions.AccountRequestPasswordReset{}),
    do: false

  def can(_, %Actions.AccountRequestPasswordReset{}),
    do: true

  def can(%{id: _}, %Actions.AccountResetPasswordAsUser{}),
    do: false

  def can(_, %Actions.AccountResetPasswordAsUser{}),
    do: true

  def can(%{id: _}, %Actions.RegistrationCreateAsUser{}),
    do: false

  def can(_, %Actions.RegistrationCreateAsUser{}),
    do: true

  def can(%{id: _}, %Actions.RegistrationConfirmAsUser{}),
    do: false

  def can(_, %Actions.RegistrationConfirmAsUser{}),
    do: true

  def can(%{id: account_id}, %Actions.ProjectDuplicateAsUser{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.ProjectDelete{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id) and is_owner_of({:account, account_id}, proj_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerTextSizeHint{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditSetThumbnail{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditRemoveThumbnail{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentCreateInProject{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateLayerWithEdge{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentDuplicateInProject{
        project_id: proj_id,
        document_id: doc_id
      }),
      do:
        can_write(account_id, :project, proj_id) and
          ReadAccess.can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.SimulationDuplicateInProject{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemDuplicateInProject{
        project_id: proj_id
      }),
      do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.DocumentEditImportFile{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentDeleteAsUser{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditSetLayerVisibility{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateParentLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditMakeSpaceBetween{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemImportFromSnsFileInProject{
        project_id: proj_id
      }),
      do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemCreateFromRnwInProject{
        project_id: proj_id
      }),
      do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.SimulationCreateFromDocumentsInProject{
        project_id: proj_id
      }),
      do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.SimulationCreateFromShadowNetSystemInProject{
        project_id: proj_id
      }),
      do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.SimulationDeleteAsUser{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.DocumentEditDeleteBond{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemDeleteAsUser{
        shadow_net_system_id: sns_id
      }),
      do: can_write(account_id, :shadow_net_system, sns_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemRename{shadow_net_system_id: sns_id}),
    do: can_write(account_id, :shadow_net_system, sns_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerStyle{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerEdgeStyle{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerTextStyle{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerTextBody{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerBoxSize{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerTextPosition{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerEdgePosition{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerEdgeSwapDirection{
        document_id: doc_id
      }),
      do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerEdgeWaypointPosition{
        document_id: doc_id
      }),
      do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditDeleteEdgeWaypoint{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateEdgeWaypoint{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditEdgeRemoveAllWaypoints{
        document_id: doc_id
      }),
      do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerSemanticTag{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerBoxShape{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditReorderLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditMoveLayerRelative{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditDeleteLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateEdgeBond{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditUnlinkLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLinkLayer{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditLayerAssignSocketSchema{
        document_id: doc_id
      }),
      do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditRemoveLayerSocketSchema{
        document_id: doc_id
      }),
      do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditCreateSnapshot{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentSnapshotRestore{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditSnapshotCreateLabel{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditSnapshotRemoveLabel{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentSnapshotsPrune{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentUpdateMeta{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditInsertDocument{
        source_document_id: src_doc_id,
        target_document_id: tgt_document_id
      }),
      do:
        can_write(account_id, :document, tgt_document_id) and
          ReadAccess.can_read(account_id, :document, src_doc_id)

  def can(%{id: account_id}, %Actions.DocumentEditPasteLayers{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.SimulationRename{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.DocumentEditReorderLayerRelative{document_id: doc_id}),
    do: can_write(account_id, :document, doc_id)

  def can(%{is_admin: true}, %Actions.GlobalPrimitivesCreateGroup{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalPrimitivesDeleteGroup{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalPrimitivesDeleteDefinition{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalPrimitivesCreateDefinition{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSocketSchemaDeleteSocket{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSocketSchemaCreateSocket{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSocketSchemaCreate{}), do: true
  def can(%{is_admin: true}, %Actions.GlobalSocketSchemaDelete{}), do: true
  def can(%{is_admin: true}, %Actions.GlobalSocketSchemaUpdate{}), do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxCreate{}), do: true
  def can(%{is_admin: true}, %Actions.GlobalSyntaxDelete{}), do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxDeleteWhitelistEntry{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxDeleteAutoTargetEntry{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxMakeDefault{}), do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxAddWhitelistEntry{}),
    do: true

  def can(%{is_admin: true}, %Actions.GlobalSyntaxAddAutoTargetEntry{}),
    do: true

  def can(%{id: account_id}, %Actions.ProjectCreateAsUser{account_id: account_id}), do: true

  def can(%{id: account_id}, %Actions.ProjectRename{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.ProjectRemoveMemberAsUser{
        project_id: proj_id,
        member_id: member_id
      }),
      do:
        can_write(account_id, :project, proj_id) and
          not is_owner_of({:member, member_id}, proj_id) and
          is_owner_of({:account, account_id}, proj_id)

  def can(%{id: account_id}, %Actions.ProjectInviteMember{project_id: proj_id}),
    do:
      can_write(account_id, :project, proj_id) and
        is_owner_of({:account, account_id}, proj_id)

  def can(%{id: account_id}, %Actions.ProjectRevokeInvitation{project_id: proj_id}),
    do:
      can_write(account_id, :project, proj_id) and
        is_owner_of({:account, account_id}, proj_id)

  def can(%{id: account_id}, %Actions.ProjectRejectInvitation{account_id: account_id}),
    do: true

  def can(%{id: account_id}, %Actions.ProjectAcceptInvitation{invitation_id: inv_id}),
    do: can_write(account_id, :invitation, inv_id)

  def can(%{id: account_id}, %Actions.ProjectMemberWithdraw{
        account_id: account_id,
        project_id: proj_id
      }),
      do: not is_owner_of({:account, account_id}, proj_id)

  def can(_, %Actions.ProjectMemberWithdraw{}), do: false

  def can(%{id: account_id}, %Actions.SimulationLogDebug{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationPause{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationInitialize{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationInstancesClear{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationLogClear{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationPlay{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationStep{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationTerminate{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.SimulationReset{simulation_id: sim_id}),
    do: can_write(account_id, :simulation, sim_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemSetNetDocument{
        shadow_net_system_id: sns_id,
        document_id: doc_id
      }),
      do:
        can_write(account_id, :shadow_net_system, sns_id) and
          ReadAccess.can_read(account_id, :document, doc_id)

  def can(%{id: account_id}, %Actions.ShadowNetSystemSetMainNet{
        shadow_net_system_id: sns_id
      }),
      do: can_write(account_id, :shadow_net_system, sns_id)

  def can(%{id: account_id}, %Actions.ProjectMediaCreateSvg{project_id: proj_id}),
    do: can_write(account_id, :project, proj_id)

  def can(%{id: account_id}, %Actions.DocumentMoveIntoProject{
        document_id: doc_id,
        project_id: proj_id
      }),
      do:
        can_write(account_id, :project, proj_id) and
          ReadAccess.can_read(account_id, :document, doc_id)

  def can(%{id: account_id} = account, %Actions.AccountChangePasswordAsUser{
        account_id: account_id,
        change: %{"old_password" => old_password}
      }),
      do: RenewCollabAuth.Entities.Account.valid_password?(account, old_password)

  def can(%{id: account_id}, %Actions.AccountDeleteAsUser{account_id: account_id}),
    do: true

  def can(%{is_admin: true}, %Actions.ProjectCreateAsAdmin{}), do: true

  def can(%{is_admin: true}, %Actions.ProjectAddDocumentAsAdmin{}),
    do: true

  def can(%{is_admin: true}, %Actions.ProjectRemoveDocumentAsAdmin{}),
    do: true

  def can(%{is_admin: true}, %Actions.ProjectAddSimulationAsAdmin{}),
    do: true

  def can(%{is_admin: true}, %Actions.ProjectRemoveSimulationAsAdmin{}),
    do: true

  def can(%{is_admin: true}, %Actions.ProjectAddShadowNetSystemAsAdmin{}),
    do: true

  def can(
        %{is_admin: true},
        %Actions.ProjectRemoveShadowNetSystemAsAdmin{}
      ),
      do: true

  def can(%{is_admin: true}, %Actions.ProjectDuplicateAsAdmin{}), do: true
  def can(%{is_admin: true}, %Actions.ProjectAddMemberAsAdmin{}), do: true

  def can(%{is_admin: true}, %Actions.ProjectRemoveMemberAsAdmin{}),
    do: true

  def can(%{is_admin: true, id: account_id}, %Actions.AccountDeleteAsAdmin{account_id: account_id}),
      do: false

  def can(%{is_admin: true}, %Actions.AccountDeleteAsAdmin{}),
    do: true

  def can(%{is_admin: true}, %Actions.AccountCreateAsAdmin{}),
    do: true

  def can(%{is_admin: true, id: account_id}, %Actions.AccountSetAdmin{account_id: account_id}),
    do: false

  def can(%{is_admin: true}, %Actions.AccountSetAdmin{}),
    do: true

  def can(_account, _action), do: false

  def can_write(account_id, :project, proj_id),
    do: check_access(account_id, {:project, proj_id}, [:editor, :owner])

  def can_write(account_id, :simulation, sim_id),
    do: check_access(account_id, {:simulation, sim_id}, [:editor, :owner])

  def can_write(account_id, :shadow_net_system, sns_id),
    do: check_access(account_id, {:shadow_net_system, sns_id}, [:editor, :owner])

  def can_write(account_id, :document, doc_id),
    do: check_access(account_id, {:document, doc_id}, [:editor, :owner])

  def can_write(account_id, :media, media_id),
    do: check_access(account_id, {:media, media_id}, [:editor, :owner])

  def can_write(account_id, :invitation, inv_id),
    do: check_access(account_id, {:invitation, inv_id}, [:reader, :editor, :owner])

  defp check_access(account_id, entity, roles) do
    RenewCollabProj.Queries.CheckAccess.new(%{
      account_id: account_id,
      entity: entity,
      roles: roles
    })
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, nil} -> false
      {:ok, result} -> result
      _ -> false
    end
  end

  defp is_owner_of(account_or_member, project_id) do
    RenewCollabProj.Queries.CheckOwnership.new(%{
      account_or_member: account_or_member,
      project_id: project_id
    })
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, result} -> result
      _ -> false
    end
  end
end
