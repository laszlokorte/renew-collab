defmodule RenewCollabCtrl.Action do
  alias RenewCollabProj.Entities.Project
  alias RenewCollab.Import.Converted
  alias RenewCollab.Commands
  alias RenewCollabProj.Entities.ProjectDocument
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
        document_data: %Converted{
          name: document_name,
          kind: document_kind,
          layers: layers,
          hyperlinks: hyperlinks,
          hierarchy: hierarchy,
          bonds: bonds,
          thumbnail: thumbnail
        }
      }) do
    Commands.CreateDocument.new(%{
      doc: %TransientDocument{
        content: %{
          name: document_name,
          kind: document_kind,
          layers: layers
        },
        parenthoods: hierarchy,
        hyperlinks: hyperlinks,
        bonds: bonds,
        thumbnail: thumbnail
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

  def do_perform(%Actions.DocumentDeleteAsUser{document_id: document_id}) do
    RenewCollabProj.Queries.DocumentsProject.new(%{document_id: document_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %{document_id: doc_id, project_id: project_id}} ->
        RenewCollab.Commands.DeleteDocument.new(%{
          document_id: doc_id
        })
        |> RenewCollab.DocumentCommander.run_document_command(false)

        RenewCollabProj.Commands.RemoveProjectDocument.new(%{
          document_id: doc_id,
          project_id: project_id
        })
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()

        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project_id}/documents",
          :any
        )

        :ok

      _ ->
        :error
    end
  end

  def do_perform(%Actions.DocumentDuplicateInProject{
        document_id: document_id,
        project_id: project_id
      }) do
    RenewCollab.Commands.DuplicateDocument.new(%{
      document_id: document_id,
      keep_name: true
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync(true)
    |> case do
      {:ok,
       %{insert_document: %RenewCollab.Document.Document{id: new_document_id} = new_document}} ->
        %ProjectDocument{project_id: project_id}
        |> ProjectDocument.changeset(%{
          "document_id" => new_document_id
        })
        |> RenewCollabProj.Repo.insert()

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project_id}/documents",
          :any
        )

        {:ok, new_document}

      _ ->
        :error
    end
  end

  def do_perform(%Actions.DocumentEditCreateEdgeBond{
        document_id: document_id,
        edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      }) do
    Commands.CreateEdgeBond.new(%{
      document_id: document_id,
      edge_id: edge_id,
      kind: kind,
      layer_id: layer_id,
      socket_id: socket_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditCreateEdgeWaypoint{
        document_id: document_id,
        layer_id: layer_id,
        prev_waypoint_id: prev_waypoint_id,
        position: position
      }) do
    Commands.CreateLayerEdgeWaypoint.new(%{
      document_id: document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: position
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditDeleteBond{document_id: document_id, bond_id: bond_id}) do
    Commands.DeleteBond.new(%{
      document_id: document_id,
      bond_id: bond_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditDeleteEdgeWaypoint{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id
      }) do
    Commands.DeleteLayerEdgeWaypoint.new(%{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditDeleteLayer{
        document_id: document_id,
        layer_id: layer_id,
        delete_children: delete_children
      }) do
    RenewCollab.Commands.DeleteLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      delete_children: delete_children
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditEdgeRemoveAllWaypoints{
        document_id: document_id,
        layer_id: layer_id
      }) do
    RenewCollab.Commands.RemoveAllLayerEdgeWaypoints.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditInsertDocument{
        source_document_id: source_document_id,
        target_document_id: target_document_id,
        position: position
      }) do
    RenewCollab.Commands.InsertDocument.new(%{
      source_document_id: source_document_id,
      target_document_id: target_document_id,
      position: position
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditImportFile{
        document_id: document_id,
        file_name: file_name,
        file_content: file_content
      }) do
    with {:ok, imported} <- RenewCollab.Import.DocumentImport.import(file_name, file_content) do
      %RenewCollab.Commands.InsertTransientDocument{
        target_document_id: document_id,
        converted_document: imported,
        position: {0, 0}
      }
      |> RenewCollab.DocumentCommander.run_document_command()

      :ok
    end
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

  def do_perform(%Actions.DocumentEditLayerBoxShape{
        document_id: document_id,
        layer_id: layer_id,
        shape_id: shape_id,
        attributes: attributes
      }) do
    RenewCollab.Commands.UpdateLayerBoxShape.new(%{
      document_id: document_id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: attributes
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerBoxSize{
        document_id: document_id,
        layer_id: layer_id,
        new_size: new_size
      }) do
    RenewCollab.Commands.UpdateLayerBoxSize.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_size: new_size
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerEdgeAttributes{
        document_id: document_id,
        layer_id: layer_id,
        attributes: attributes
      }) do
    RenewCollab.Commands.UpdateLayerEdgeAttributes.new(%{
      document_id: document_id,
      layer_id: layer_id,
      attributes: attributes
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerEdgePosition{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    RenewCollab.Commands.UpdateLayerEdgePosition.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerEdgeStyle{
        document_id: document_id,
        layer_id: layer_id,
        style_attr: style_attr,
        value: value
      }) do
    RenewCollab.Commands.UpdateLayerEdgeStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerEdgeSwapDirection{
        document_id: document_id,
        layer_id: layer_id
      }) do
    RenewCollab.Commands.UpdateLayerEdgeReverseDirection.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerEdgeWaypointPosition{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id,
        new_position: new_position
      }) do
    RenewCollab.Commands.UpdateLayerEdgeWaypointPosition.new(%{
      document_id: document_id,
      waypoint_id: waypoint_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerSemanticTag{
        document_id: document_id,
        layer_id: layer_id,
        new_tag: new_tag
      }) do
    RenewCollab.Commands.UpdateLayerSemanticTag.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_tag: new_tag
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerStyle{
        document_id: document_id,
        layer_id: layer_id,
        style_attr: style_attr,
        value: value
      }) do
    RenewCollab.Commands.UpdateLayerStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerTextBody{
        document_id: document_id,
        layer_id: layer_id,
        new_body: new_body
      }) do
    RenewCollab.Commands.UpdateLayerTextBody.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_body: new_body
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerTextPosition{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    RenewCollab.Commands.UpdateLayerTextPosition.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditLayerTextStyle{
        document_id: document_id,
        layer_id: layer_id,
        style_attr: style_attr,
        value: value
      }) do
    RenewCollab.Commands.UpdateLayerTextStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLayerZIndex{
        document_id: document_id,
        layer_id: layer_id,
        z_index: z_index
      }) do
    RenewCollab.Commands.UpdateLayerZIndex.new(%{
      document_id: document_id,
      layer_id: layer_id,
      z_index: z_index
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditLinkLayer{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id
      }) do
    RenewCollab.Commands.LinkLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditUnlinkLayer{
        document_id: document_id,
        layer_id: layer_id
      }) do
    RenewCollab.Commands.UnlinkLayer.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditMakeSpaceBetween{
        document_id: document_id,
        base: base,
        direction: direction,
        inverse: inverse
      }) do
    RenewCollab.Commands.MakeSpaceBetween.new(%{
      document_id: document_id,
      base: base,
      direction: direction,
      inverse: inverse
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditMoveLayerRelative{
        document_id: document_id,
        layer_id: layer_id,
        dx: dx,
        dy: dy
      }) do
    RenewCollab.Commands.MoveLayerRelative.new(%{
      document_id: document_id,
      layer_id: layer_id,
      dx: dx,
      dy: dy
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditRemoveLayerSocketSchema{
        document_id: document_id,
        layer_id: layer_id
      }) do
    Commands.RemoveLayerSocketSchema.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditReorderLayer{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id,
        target: target
      }) do
    Commands.ReorderLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: target
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditReorderLayerRelative{
        document_id: document_id,
        layer_id: layer_id,
        target: target,
        relative_direction: relative_direction
      }) do
    Commands.ReorderLayerRelative.new(%{
      document_id: document_id,
      layer_id: layer_id,
      target: target,
      relative_direction: relative_direction
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditSetLayerVisibility{
        document_id: document_id,
        layer_id: layer_id,
        visible: :toggle
      }) do
    Commands.ToggleVisible.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentMoveIntoProject{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentRename{}) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.DocumentUpdateMeta{document_id: document_id, meta: meta}) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: document_id,
      meta: meta
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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

  def do_perform(%Actions.DocumentEditSnapshotCreateLabel{
        document_id: document_id,
        snapshot_id: snapshot_id,
        description: description
      }) do
    RenewCollab.Commands.CreateSnapshotLabel.new(%{
      document_id: document_id,
      snapshot_id: snapshot_id,
      description: description
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentEditSnapshotRemoveLabel{
        document_id: document_id,
        snapshot_id: snapshot_id
      }) do
    RenewCollab.Commands.RemoveSnapshotLabel.new(%{
      document_id: document_id,
      snapshot_id: snapshot_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
  end

  def do_perform(%Actions.DocumentSnapshotsPrune{document_id: document_id}) do
    RenewCollab.Commands.PruneSnapshots.new(%{
      document_id: document_id
    })
    |> RenewCollab.DocumentCommander.run_document_command()

    :ok
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
