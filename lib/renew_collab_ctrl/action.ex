defmodule RenewCollabCtrl.Action do
  alias RenewCollab.Commands
  alias RenewCollabProj.Entites.ProjectDocument
  alias RenewCollab.Document.TransientDocument
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

  def do_perform(%Actions.DocumentCreateInProject{
        project_id: project_id,
        document_data: document_data
      }) do
    Commands.CreateDocument.new(%{
      doc: %TransientDocument{
        content: document_data,
        parenthoods: [],
        hyperlinks: [],
        bonds: []
      }
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()
    |> case do
      {:ok, %{insert_document: insert_document}} ->
        %ProjectDocument{project_id: project_id}
        |> ProjectDocument.changeset(%{
          "document_id" => insert_document.id
        })
        |> RenewCollabProj.Repo.insert()

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project_id}/documents",
          :any
        )

        {:ok, insert_document}
    end
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

  def do_perform(%Actions.DocumentEditCreateLayerWithEdge{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentEditCreateLayer{
        document_id: document_id,
        attrs: attrs,
        base_layer_id: base_layer_id
      }) do
    Commands.CreateLayer.new(%{
      document_id: document_id,
      attrs: attrs,
      base_layer_id: base_layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditImportFile{
        document_id: document_id,
        file_name: file_name,
        file_content: file_content
      }) do
    %RenewCollab.Commands.InsertTransientDocument{
      target_document_id: document_id,
      converted_document: RenewCollab.Import.DocumentImport.import(file_name, file_content)
    }
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerAssignSocketSchema{
        document_id: document_id,
        layer_id: layer_id,
        socket_schema_id: socket_schema_id
      }) do
    RenewCollab.Commands.AssignLayerSocketSchema.new(%{
      document_id: document_id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditLayerTextSizeHint{
        document_id: document_id,
        box: box,
        layer_id: layer_id
      }) do
    RenewCollab.Commands.UpdateLayerTextSizeHint.new(%{
      document_id: document_id,
      layer_id: layer_id,
      box: box
    })
    |> RenewCollab.DocumentCommander.run_document_command(false)

    :ok
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

  def do_perform(%Actions.DocumentEditSetThumbnail{document_id: document_id, layer_id: layer_id}) do
    Commands.SetThumbnail.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditRemoveThumbnail{document_id: document_id}) do
    Commands.RemoveThumbnail.new(%{
      document_id: document_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentSnapshotRestore{
        document_id: document_id,
        snapshot_id: snapshot_id
      }) do
    RenewCollab.Commands.RestoreSnapshot.new(%{
      document_id: document_id,
      snapshot_id: snapshot_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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
