defmodule RenewCollabCtrl.Action do
  alias RenewCollabAuth.Entities.Registration
  alias RenewCollab.Media
  alias RenewCollab.Syntax
  alias RenewCollab.Sockets
  alias RenewCollab.Primitives
  alias RenewCollab.Import.Converted
  alias RenewCollab.Commands
  alias RenewCollabProj.Entities.ProjectDocument
  alias RenewCollab.Document.TransientDocument
  alias RenewCollabCtrl.Actions

  def do_perform(%Actions.AccountSetAdmin{account_id: account_id, admin: admin}) do
    RenewCollabAuth.Commands.UpdateAccount.new(%{
      account_id: account_id,
      attributes: %{is_admin: admin}
    })
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
  end

  def do_perform(%Actions.AccountChangePasswordAsUser{account_id: account_id, change: change}) do
    RenewCollabAuth.Commands.UpdateOwnAccount.new(%{
      account_id: account_id,
      attributes: change
    })
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  def do_perform(%Actions.AccountCreateAsAdmin{account: account}) do
    RenewCollabAuth.Commands.CreateAccount.new(%{account: account})
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{account: account}} ->
        RenewCollabProj.Commands.AssignInvitationsToNewAccount.new(%{
          account_id: account.id,
          email: account.email
        })
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()

        {:ok, account}

      {:error, :account, changeset, _} ->
        {:error, changeset}
    end
  end

  def do_perform(%Actions.AccountDeleteAsAdmin{account_id: account_id}) do
    RenewCollabAuth.Commands.DeleteAccount.new(%{account_id: account_id})
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{delete_account: _}} -> :ok
      {:error, :account, _changeset, _} -> :error
    end
  end

  def do_perform(%Actions.AccountDeleteAsUser{account_id: account_id}) do
    RenewCollabAuth.Commands.DeleteAccount.new(%{account_id: account_id})
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{delete_account: _}} -> :ok
      {:error, :account, _changeset, _} -> :error
    end
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
      keep_name: false
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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditCreateLayerWithEdge{
        document_id: document_id,
        attrs: attrs,
        edge: with_edge,
        base_layer_id: base_layer_id
      }) do
    RenewCollab.Commands.CreateLayerWithEdge.new(%{
      base_layer_id: base_layer_id,
      document_id: document_id,
      edge: with_edge,
      attrs: attrs
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()
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
    |> RenewCollab.DocumentCommander.run_document_command_sync()
  end

  def do_perform(%Actions.DocumentEditCreateParentLayer{
        document_id: document_id,
        attrs: attrs,
        child_layer_id: child_layer_id,
        layer_ids: layer_ids
      }) do
    RenewCollab.Commands.CreateParentLayer.new(%{
      layer_ids: create_parent_layer_ids(layer_ids, child_layer_id),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(attrs, "semantic_tag", "CH.ifa.draw.figures.GroupFigure")
      }
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()
  end

  def do_perform(%Actions.DocumentEditDeleteBond{document_id: document_id, bond_id: bond_id}) do
    Commands.DeleteBond.new(%{
      document_id: document_id,
      bond_id: bond_id
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditDeleteLayer{
        document_id: document_id,
        layer_ids: layer_ids,
        delete_children: delete_children
      }) do
    RenewCollab.Commands.DeleteLayer.new(%{
      document_id: document_id,
      layer_ids: layer_ids,
      delete_children: delete_children
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditPasteLayers{
        document_id: document_id,
        clipboard: clipboard,
        position: position
      }) do
    RenewCollab.Commands.InsertLayerClipboard.new(%{
      document_id: document_id,
      clipboard: clipboard,
      position: position
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()
    |> case do
      {:ok, %{inserted_layer_ids: layer_ids}} -> {:ok, %{layer_ids: layer_ids}}
      other -> other
    end
  end

  def do_perform(%Actions.DocumentEditImportFile{
        document_id: document_id,
        file_name: file_name,
        file_content: file_content,
        x: x,
        y: y
      }) do
    with {:ok, imported} <- RenewCollab.Import.DocumentImport.import(file_name, file_content) do
      %RenewCollab.Commands.InsertTransientDocument{
        target_document_id: document_id,
        converted_document: imported,
        position: {x, y}
      }
      |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()
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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditMoveLayerRelative{
        document_id: document_id,
        layer_ids: layer_ids,
        dx: dx,
        dy: dy
      }) do
    RenewCollab.Commands.MoveLayerRelative.new(%{
      document_id: document_id,
      layer_ids: layer_ids,
      dx: dx,
      dy: dy
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditReorderLayer{
        document_id: document_id,
        layer_ids: layer_ids,
        target_layer_id: target_layer_id,
        target: target
      }) do
    Commands.ReorderLayers.new(%{
      document_id: document_id,
      layer_ids: layer_ids,
      target_layer_id: target_layer_id,
      target: target
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditReorderLayerRelative{
        document_id: document_id,
        layer_ids: layer_ids,
        target: target,
        relative_direction: relative_direction
      }) do
    Commands.ReorderLayersRelative.new(%{
      document_id: document_id,
      layer_ids: layer_ids,
      target: target,
      relative_direction: relative_direction
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditSetThumbnail{document_id: document_id, layer_id: layer_id}) do
    Commands.SetThumbnail.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditRemoveThumbnail{document_id: document_id}) do
    Commands.RemoveThumbnail.new(%{
      document_id: document_id
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditSetLayerVisibility{
        document_id: document_id,
        layer_id: layer_id,
        visible: visible
      }) do
    Commands.SetVisibility.new(%{
      document_id: document_id,
      layer_id: layer_id,
      visible: visible
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentMoveIntoProject{
        project_id: project_id,
        document_id: document_id
      }) do
    RenewCollabProj.Commands.AssignProjectDocument.new(%{
      project_id: project_id,
      document_id: document_id,
      allow_move: true
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectRename{project_id: project_id, new_name: name}) do
    %RenewCollabProj.Commands.UpdateProjectMeta{
      project_id: project_id,
      attributes: %{
        name: name
      }
    }
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.DocumentUpdateMeta{document_id: document_id, meta: meta}) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: document_id,
      meta: meta
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentEditCreateSnapshot{
        document_id: document_id
      }) do
    RenewCollab.Commands.CreateSnapshot.new(%{
      document_id: document_id
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

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
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.DocumentSnapshotsPrune{document_id: document_id}) do
    RenewCollab.Commands.PruneSnapshots.new(%{
      document_id: document_id
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.ProjectAddMemberAsAdmin{
        project_id: project_id,
        account_id: account_id,
        role: role
      }) do
    RenewCollabProj.Commands.AssignProjectMember.new(%{
      project_id: project_id,
      account_id: account_id,
      role: role
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectAddDocumentAsAdmin{
        project_id: project_id,
        document_id: document_id
      }) do
    RenewCollabProj.Commands.AssignProjectDocument.new(%{
      project_id: project_id,
      document_id: document_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectInviteMember{project_id: project_id, email: email, role: role}) do
    existing_account_id =
      RenewCollabAuth.Queries.AccountByEmail.new(%{email: email})
      |> RenewCollabAuth.AuthFetcher.fetch()
      |> case do
        {:ok, %{id: account_id}} ->
          account_id

        _ ->
          nil
      end

    RenewCollabProj.Commands.CreateInvitation.new(%{
      project_id: project_id,
      email: email,
      role: role,
      account_id: existing_account_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
    |> case do
      {:ok, %{invitation: invitation}} -> {:ok, invitation}
      {:error, :invitation, changset, _} -> {:error, changset}
    end
  end

  def do_perform(%Actions.ProjectRevokeInvitation{
        project_id: project_id,
        invitation_id: invitation_id
      }) do
    RenewCollabProj.Commands.RevokeInvitation.new(%{
      project_id: project_id,
      invitation_id: invitation_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
    |> case do
      {:ok, %{invitation: invitation}} -> {:ok, invitation}
    end
  end

  def do_perform(%Actions.ProjectRejectInvitation{
        project_id: project_id,
        account_id: account_id
      }) do
    RenewCollabProj.Commands.RevokeInvitation.new(%{
      project_id: project_id,
      account_id: account_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectAcceptInvitation{
        project_id: project_id,
        invitation_id: invitation_id
      }) do
    RenewCollabProj.Commands.AcceptInvitation.new(%{
      project_id: project_id,
      invitation_id: invitation_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
    |> case do
      {:ok, %{add_member: membership}} -> {:ok, membership}
    end
  end

  def do_perform(%Actions.ProjectAddSimulationAsAdmin{
        project_id: project_id,
        simulation_id: simulation_id
      }) do
    RenewCollabProj.Commands.AssignProjectSimulation.new(%{
      project_id: project_id,
      simulation_id: simulation_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectAddShadowNetSystemAsAdmin{
        project_id: project_id,
        shadow_net_system_id: shadow_net_system_id
      }) do
    RenewCollabProj.Commands.AssignProjectShadowNetSystem.new(%{
      project_id: project_id,
      shadow_net_system_id: shadow_net_system_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectCreateAsUser{project_name: name, account_id: account_id}) do
    %RenewCollabProj.Commands.CreateProject{name: name, owner_account_id: account_id}
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
    |> case do
      {:ok, %{project: project}} ->
        {:ok, project}
    end
  end

  def do_perform(%Actions.ProjectCreateAsAdmin{project_name: name}) do
    %RenewCollabProj.Commands.CreateProject{name: name}
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectDelete{project_id: project_id}) do
    %RenewCollabProj.Commands.DeleteProject{project_id: project_id}
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()

    :ok
  end

  def do_perform(%Actions.ProjectDuplicateAsAdmin{project_id: project_id}) do
    %RenewCollabProj.Queries.ProjectDetails{project_id: project_id}
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %{name: original_name} = original_project} ->
        new_name = original_name

        %RenewCollabProj.Commands.CreateProject{name: new_name, owner_account_id: nil}
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()
        |> case do
          {:ok, %{project: %{id: new_project_id}}} ->
            for %{document_id: original_document_id} <- original_project.documents, reduce: :ok do
              :ok ->
                RenewCollab.Commands.DuplicateDocument.new(%{
                  document_id: original_document_id,
                  keep_name: true
                })
                |> RenewCollab.DocumentCommander.run_document_command_sync(true)
                |> case do
                  {:ok,
                   %{
                     insert_document: %RenewCollab.Document.Document{id: new_document_id}
                   }} ->
                    %ProjectDocument{project_id: new_project_id}
                    |> ProjectDocument.changeset(%{
                      "document_id" => new_document_id
                    })
                    |> RenewCollabProj.Repo.insert()

                    :ok

                  _err ->
                    :ok
                end

              err ->
                err
            end
        end
    end
  end

  def do_perform(%Actions.ProjectDuplicateAsUser{account_id: account_id, project_id: project_id}) do
    %RenewCollabProj.Queries.ProjectDetails{project_id: project_id}
    |> RenewCollabProj.ProjectFetcher.fetch()
    |> case do
      {:ok, %{name: original_name} = original_project} ->
        new_name = original_name |> RenewCollabCtrl.Naming.name_for_copy()

        %RenewCollabProj.Commands.CreateProject{name: new_name, owner_account_id: account_id}
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()
        |> case do
          {:ok, %{project: %{id: new_project_id}}} ->
            for %{document_id: original_document_id} <- original_project.documents, reduce: :ok do
              :ok ->
                RenewCollab.Commands.DuplicateDocument.new(%{
                  document_id: original_document_id,
                  keep_name: true
                })
                |> RenewCollab.DocumentCommander.run_document_command_sync(true)
                |> case do
                  {:ok,
                   %{
                     insert_document: %RenewCollab.Document.Document{id: new_document_id}
                   }} ->
                    %ProjectDocument{project_id: new_project_id}
                    |> ProjectDocument.changeset(%{
                      "document_id" => new_document_id
                    })
                    |> RenewCollabProj.Repo.insert()

                    :ok

                  err ->
                    err
                end

              err ->
                err
            end
        end
    end
  end

  def do_perform(%Actions.ProjectRemoveDocumentAsAdmin{
        project_id: project_id,
        document_id: document_id
      }) do
    RenewCollabProj.Commands.RemoveProjectDocument.new(%{
      project_id: project_id,
      document_id: document_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectRemoveMemberAsUser{
        project_id: project_id,
        member_id: member_id
      }) do
    RenewCollabProj.Commands.RemoveProjectMember.new(%{
      project_id: project_id,
      member_id: member_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectMemberWithdraw{
        project_id: project_id,
        account_id: account_id
      }) do
    RenewCollabProj.Commands.RemoveProjectMember.new(%{
      project_id: project_id,
      account_id: account_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()

    :ok
  end

  def do_perform(%Actions.ProjectRemoveSimulationAsAdmin{
        project_id: project_id,
        simulation_id: simulation_id
      }) do
    RenewCollabProj.Commands.RemoveProjectSimulation.new(%{
      project_id: project_id,
      simulation_id: simulation_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectRemoveShadowNetSystemAsAdmin{
        project_id: project_id,
        shadow_net_system_id: shadow_net_system_id
      }) do
    RenewCollabProj.Commands.RemoveProjectShadowNetSystem.new(%{
      project_id: project_id,
      shadow_net_system_id: shadow_net_system_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.ProjectRemoveMemberAsAdmin{
        project_id: project_id,
        account_id: account_id
      }) do
    RenewCollabProj.Commands.RemoveProjectMember.new(%{
      project_id: project_id,
      account_id: account_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()
  end

  def do_perform(%Actions.DocumentRename{document_id: document_id, new_name: new_name}) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: document_id,
      meta: %{
        name: new_name
      }
    })
    |> RenewCollab.DocumentCommander.run_document_command_sync()

    :ok
  end

  def do_perform(%Actions.SimulationCreateFromShadowNetSystemInProject{
        project_id: project_id,
        shadow_net_system_id: sns_id
      }) do
    RenewCollabSim.Commands.CreateSimulation.new(%{
      shadow_net_system_id: sns_id,
      document_ids: []
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
    |> case do
      {:ok, %{simulation: %{id: sim_id} = simulation}} ->
        RenewCollabProj.Commands.AssignProjectSimulation.new(%{
          project_id: project_id,
          simulation_id: sim_id
        })
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()

        {:ok, simulation}

      e ->
        {:error, e}
    end
  end

  def do_perform(%Actions.SimulationCreateFromDocumentsInProject{
        project_id: project_id,
        document_ids: document_ids,
        formalism: formalism,
        main_net_name: main_net_name
      }) do
    with {:ok, project} <-
           %RenewCollabProj.Queries.ProjectDetails{project_id: project_id}
           |> RenewCollabProj.ProjectFetcher.fetch(),
         {:ok, nets} <- simulation_nets(project, document_ids),
         [%{net_name: default_main_name} | _] <- nets,
         main_name = main_net_name || default_main_name,
         {:ok, content} <-
           RenewCollabSim.Compiler.SnsCompiler.compile(
             formalism,
             nets
             |> Enum.map(fn %{net_name: name, rnw: rnw} -> {name, rnw} end)
           ),
         {:ok, %{shadow_net_system: %{id: sns_id}}} <-
           RenewCollabSim.Commands.CreateShadowNetSystem.new(%{
             label: "Fooo",
             compiled: content,
             main_net_name: main_name,
             nets:
               nets
               |> Enum.map(fn %{
                                net_name: net_name,
                                document_json: document_json,
                                thumbnail_json: thumbnail_json
                              } ->
                 %{
                   "name" => net_name,
                   "document_json" => document_json,
                   "thumbnail_json" => thumbnail_json
                 }
               end)
           })
           |> RenewCollabSim.SimulationCommander.run_simulation_command_sync() do
      RenewCollabProj.Commands.AssignProjectShadowNetSystem.new(%{
        project_id: project_id,
        shadow_net_system_id: sns_id
      })
      |> RenewCollabProj.ProjectCommander.run_project_command_sync()

      RenewCollabSim.Commands.CreateSimulation.new(%{
        shadow_net_system_id: sns_id
      })
      |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
      |> case do
        {:ok, %{simulation: %{id: sim_id} = simulation}} ->
          RenewCollabProj.Commands.AssignProjectSimulation.new(%{
            project_id: project_id,
            simulation_id: sim_id
          })
          |> RenewCollabProj.ProjectCommander.run_project_command_sync()

          RenewCollab.Commands.LinkDocumenstToSimulation.new(%{
            simulation_id: sim_id,
            document_ids:
              nets
              |> Enum.map(fn %{snapshot_id: snap_id} -> snap_id end)
          })
          |> RenewCollab.DocumentCommander.run_document_command_sync()

          {:ok, simulation}

        e ->
          {:error, e}
      end
    else
      [] -> {:error, :no_documents}
      {:error, reason} -> {:error, reason}
      e -> {:error, e}
    end
  end

  defp simulation_nets(project, document_ids) do
    document_id_set = MapSet.new(document_ids)

    actual_document_ids =
      project.documents
      |> Enum.map(fn %{document_id: id} -> id end)
      |> Enum.filter(&MapSet.member?(document_id_set, &1))

    try do
      {:ok,
       actual_document_ids
       |> Enum.map(fn doc_id ->
         {:ok, document} =
           %{document_id: doc_id}
           |> RenewCollab.Queries.DocumentWithElements.new()
           |> RenewCollab.DocumentFetcher.fetch()

         {:ok, document_thumbnail} =
           %{document_id: doc_id, root_layer_id: :thumbnail}
           |> RenewCollab.Queries.DocumentWithElements.new()
           |> RenewCollab.DocumentFetcher.fetch()

         {:ok, rnw} = RenewCollab.Export.DocumentExport.export(document, synthetic: true)

         {:ok, document_json} =
           RenewCollabWeb.DocumentJSON.show_content(document) |> Jason.encode()

         {:ok, thumbnail_json} =
           RenewCollabWeb.DocumentJSON.show_content(document_thumbnail, 0) |> Jason.encode()

         %{
           net_name: RenewCollabSim.Compiler.SnsCompiler.normalize_net_name(document.name),
           rnw: rnw,
           document_json: document_json,
           thumbnail_json: thumbnail_json,
           snapshot_id: {document.id, document.current_snaptshot.id}
         }
       end)}
    rescue
      e ->
        {:error, {:export_error, e}}
    end
  end

  def do_perform(%Actions.ShadowNetSystemImportFromSnsFileInProject{
        main_net_name: main_name,
        project_id: project_id,
        sns_file: {file_name, file_content}
      }) do
    {:ok, %{shadow_net_system: %{id: sns_id} = sns}} =
      RenewCollabSim.Commands.CreateShadowNetSystem.new(%{
        label: "Imported: #{file_name}",
        compiled: file_content,
        main_net_name: main_name,
        nets: []
      })
      |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()

    RenewCollabProj.Commands.AssignProjectShadowNetSystem.new(%{
      project_id: project_id,
      shadow_net_system_id: sns_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()

    {:ok, sns}
  end

  def do_perform(%Actions.ShadowNetSystemCreateFromRnwInProject{
        formalism: formalism,
        main_net_name: main_name,
        project_id: project_id,
        rnws: rnws
      }) do
    with {:ok, content} <-
           RenewCollabSim.Compiler.SnsCompiler.compile(
             formalism,
             rnws
           ),
         {:ok, %{shadow_net_system: %{id: sns_id} = sns}} <-
           RenewCollabSim.Commands.CreateShadowNetSystem.new(%{
             label: "Fooo",
             compiled: content,
             main_net_name: main_name,
             nets: []
           })
           |> RenewCollabSim.SimulationCommander.run_simulation_command_sync() do
      RenewCollabProj.Commands.AssignProjectShadowNetSystem.new(%{
        project_id: project_id,
        shadow_net_system_id: sns_id
      })
      |> RenewCollabProj.ProjectCommander.run_project_command_sync()

      {:ok, sns}
    else
      {:error, reason} -> {:error, reason}
      e -> {:error, e}
    end
  end

  def do_perform(%Actions.ShadowNetSystemDeleteAsUser{shadow_net_system_id: shadow_net_system_id}) do
    {:ok, %{id: project_id}} =
      %RenewCollabProj.Queries.ShadowNetsProject{shadow_net_system_id: shadow_net_system_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabProj.Commands.RemoveProjectShadowNetSystem.new(%{
      project_id: project_id,
      shadow_net_system_id: shadow_net_system_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()

    RenewCollabSim.Commands.DeleteShadowNetSystem.new(%{
      shadow_net_system_id: shadow_net_system_id
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()

    :ok
  end

  def do_perform(%Actions.ShadowNetSystemDuplicateInProject{
        project_id: _project_id,
        shadow_net_system_id: _sns_id
      }) do
    {:error, :not_implemented}
  end

  def do_perform(%Actions.SimulationDuplicateInProject{
        project_id: project_id,
        simulation_id: simulation_id
      }) do
    RenewCollabSim.Queries.Simulation.new(%{simulation_id: simulation_id, detailed: true})
    |> RenewCollabSim.SimulationFetcher.fetch()
    |> case do
      {:ok, %{} = original_sim} ->
        RenewCollabSim.Commands.CreateSimulation.new(%{
          shadow_net_system_id: original_sim.shadow_net_system_id,
          document_ids: []
        })
        |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
        |> case do
          {:ok, %{simulation: %{id: sim_id} = simulation}} ->
            RenewCollabProj.Commands.AssignProjectSimulation.new(%{
              project_id: project_id,
              simulation_id: sim_id
            })
            |> RenewCollabProj.ProjectCommander.run_project_command_sync()

            {:ok, simulation}

          e ->
            {:error, e}
        end
    end
  end

  def do_perform(%Actions.ShadowNetSystemRename{shadow_net_system_id: sns_id, new_name: new_name}) do
    RenewCollabSim.Commands.RenameShadowNetSystem.new(%{
      shadow_net_system_id: sns_id,
      new_name: new_name
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationDeleteAsUser{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabProj.Commands.RemoveProjectSimulation.new(%{
      project_id: project_id,
      simulation_id: simulation_id
    })
    |> RenewCollabProj.ProjectCommander.run_project_command_sync()

    RenewCollabSim.Commands.DeleteSimulation.new(%{simulation_id: simulation_id})
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()

    RenewCollabSim.Server.ScopedSimulationServer.stop(
      project_id,
      simulation_id
    )

    :ok
  end

  def do_perform(%Actions.SimulationInitialize{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.setup_and_wait(project_id, simulation_id, [
      "projects/#{project_id}/simulations"
    ])
  end

  def do_perform(%Actions.SimulationInstancesClear{simulation_id: simulation_id}) do
    RenewCollabSim.Commands.ClearInstances.new(%{
      simulation_id: simulation_id
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationLogClear{simulation_id: simulation_id}) do
    RenewCollabSim.Commands.ClearLog.new(%{
      simulation_id: simulation_id
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationLogDebug{simulation_id: simulation_id, message: message}) do
    RenewCollabSim.Commands.AddManualLogEntry.new(%{
      simulation_id: simulation_id,
      log_message: "[MANUAL DEBUG] #{message}"
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationPause{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.pause(project_id, simulation_id)
  end

  def do_perform(%Actions.SimulationPlay{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.play(project_id, simulation_id)
  end

  def do_perform(%Actions.SimulationRename{simulation_id: simulation_id, new_name: new_name}) do
    RenewCollabSim.Commands.RenameSimulation.new(%{
      simulation_id: simulation_id,
      new_name: new_name
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationReset{simulation_id: simulation_id}) do
    RenewCollabSim.Commands.ClearSimulation.new(%{
      simulation_id: simulation_id
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.SimulationStep{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.step(project_id, simulation_id)
  end

  def do_perform(%Actions.SimulationNetStep{
        simulation_id: simulation_id,
        net_instance_label: net_instance_label
      }) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.net_step(
      project_id,
      simulation_id,
      net_instance_label
    )
  end

  def do_perform(%Actions.SimulationTransitionBindings{
        simulation_id: simulation_id,
        net_instance_label: net_instance_label,
        transition_id: transition_id
      }) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.transition_bindings(
      project_id,
      simulation_id,
      net_instance_label,
      transition_id
    )
  end

  def do_perform(%Actions.SimulationFireTransition{
        simulation_id: simulation_id,
        net_instance_label: net_instance_label,
        transition_id: transition_id,
        binding_index: binding_index
      }) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.fire_transition(
      project_id,
      simulation_id,
      net_instance_label,
      transition_id,
      binding_index
    )
  end

  def do_perform(%Actions.SimulationTerminate{simulation_id: simulation_id}) do
    {:ok, %{project_id: project_id}} =
      %RenewCollabProj.Queries.SimulationsProject{simulation_id: simulation_id}
      |> RenewCollabProj.ProjectFetcher.fetch()

    RenewCollabSim.Server.ScopedSimulationServer.stop(project_id, simulation_id)
    :ok
  end

  def do_perform(%Actions.SystemReinstall{}) do
    :ok
  end

  def do_perform(%Actions.GlobalPrimitivesCreateGroup{attributes: attrs}) do
    Primitives.create_group(attrs)
  end

  def do_perform(%Actions.GlobalPrimitivesDeleteGroup{group_id: group_id}) do
    Primitives.delete_group(group_id)
  end

  def do_perform(%Actions.GlobalPrimitivesCreateDefinition{attributes: attrs}) do
    Primitives.create_primitive(
      attrs
      |> Map.update("data", nil, fn
        "" ->
          nil

        s ->
          case Jason.decode(s) do
            {:ok, j} -> j
            _ -> s
          end
      end)
    )
  end

  def do_perform(%Actions.GlobalPrimitivesDeleteDefinition{definition_id: definition_id}) do
    Primitives.delete_primitive(definition_id)
  end

  def do_perform(%Actions.GlobalSocketSchemaDeleteSocket{socket_schema_socket_id: socket_id}) do
    Sockets.delete_socket(socket_id)
  end

  def do_perform(%Actions.GlobalSocketSchemaCreateSocket{attributes: attrs}) do
    Sockets.create_socket(attrs)

    :ok
  end

  def do_perform(%Actions.GlobalSocketSchemaCreate{attributes: attrs}) do
    Sockets.create_socket_schema(attrs)
  end

  def do_perform(%Actions.GlobalSocketSchemaDelete{socket_schema_id: socket_schema_id}) do
    Sockets.delete_socket_schema(socket_schema_id)
  end

  def do_perform(%Actions.GlobalSocketSchemaUpdate{
        socket_schema_id: socket_schema_id,
        attributes: attrs
      }) do
    Sockets.change_schema(socket_schema_id, attrs)
  end

  def do_perform(%Actions.GlobalSyntaxCreate{attributes: attrs}) do
    Syntax.create(attrs)
    :ok
  end

  def do_perform(%Actions.GlobalSyntaxDelete{syntax_id: syntax_id}) do
    Syntax.delete(syntax_id)
    :ok
  end

  def do_perform(%Actions.GlobalSyntaxDeleteWhitelistEntry{whitelist_id: whitelist_list_id}) do
    Syntax.delete_whitelist(whitelist_list_id)
    :ok
  end

  def do_perform(%Actions.GlobalSyntaxDeleteAutoTargetEntry{auto_target_id: auto_target_id}) do
    Syntax.delete_autonode(auto_target_id)
    :ok
  end

  def do_perform(%Actions.GlobalSyntaxMakeDefault{syntax_id: syntax_id}) do
    Syntax.make_default(syntax_id)
    :ok
  end

  def do_perform(%Actions.GlobalSyntaxAddWhitelistEntry{attributes: attrs}) do
    Syntax.add_whitelist(attrs)
    :ok
  end

  def do_perform(%Actions.ProjectMediaCreateSvg{project_id: project_id, svg: svg}) do
    Media.create_svg(svg)
    |> case do
      {:ok, %{insert_assignment: %{id: media_id}}} ->
        RenewCollabProj.Commands.AssignProjectMedia.new(%{
          project_id: project_id,
          media_id: media_id
        })
        |> RenewCollabProj.ProjectCommander.run_project_command_sync()

      err ->
        err
    end
  end

  def do_perform(%Actions.GlobalSyntaxAddAutoTargetEntry{attributes: attrs}) do
    Syntax.add_autonode(attrs)
  end

  def do_perform(%Actions.ShadowNetSystemSetNetDocument{
        shadow_net_system_id: sns_id,
        net_id: net_id,
        document_id: document_id
      }) do
    if is_nil(document_id) do
      RenewCollabSim.Commands.ChangeShadowNetDocument.new(%{
        shadow_net_system_id: sns_id,
        shadow_net_id: net_id,
        document_json: nil
      })
      |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
    else
      {:ok, document} =
        %{document_id: document_id}
        |> RenewCollab.Queries.DocumentWithElements.new()
        |> RenewCollab.DocumentFetcher.fetch()

      RenewCollabSim.Commands.ChangeShadowNetDocument.new(%{
        shadow_net_system_id: sns_id,
        shadow_net_id: net_id,
        document_json: RenewCollabWeb.DocumentJSON.show(%{document: document}) |> JSON.encode!()
      })
      |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
    end
  end

  def do_perform(%Actions.ShadowNetSystemSetMainNet{
        shadow_net_system_id: sns_id,
        main_net_name: main_net
      }) do
    RenewCollabSim.Commands.ChangeMainNetName.new(%{
      shadow_net_system_id: sns_id,
      main_net: main_net
    })
    |> RenewCollabSim.SimulationCommander.run_simulation_command_sync()
  end

  def do_perform(%Actions.AccountRequestPasswordReset{email: email}) do
    RenewCollabAuth.Commands.CreatePasswordResetRequest.new(%{email: email})
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{reset_request: reset, account: account}} ->
        {:ok, reset |> Map.put(:account, account)}

      {:error, :reset_request, changeset, _} ->
        {:error, changeset}
    end
  end

  def do_perform(%Actions.AccountResetPasswordAsUser{reset_id: reset_id, account: account}) do
    RenewCollabAuth.Commands.ApplyPasswordResetRequest.new(%{
      reset_id: reset_id,
      account: account
    })
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{reset_request: _reset}} ->
        :ok

      {:error, :account, changeset, _} ->
        {:error, changeset}

      _ ->
        :error
    end
  end

  def do_perform(%Actions.RegistrationCreateAsUser{email: email}) do
    RenewCollabAuth.Commands.CreateRegistration.new(%{email: email})
    |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
    |> case do
      {:ok, %{registration: reg}} ->
        {:ok, reg}

      {:error, :registration, changeset, _} ->
        {:error, changeset}
    end
  end

  def do_perform(%Actions.RegistrationConfirmAsUser{
        registration_id: registration_id,
        account: account
      }) do
    RenewCollabAuth.Queries.RegisrationById.new(%{registration_id: registration_id})
    |> RenewCollabAuth.AuthFetcher.fetch()
    |> case do
      {:ok, %Registration{email: email}} ->
        RenewCollabAuth.Commands.CreateAccountFromRegistration.new(%{
          registration_id: registration_id,
          email: email,
          account: account
        })
        |> RenewCollabAuth.AuthCommander.run_auth_command_sync()
        |> case do
          {:ok, %{account: %RenewCollabAuth.Entities.Account{} = account}} ->
            RenewCollabProj.Commands.AssignInvitationsToNewAccount.new(%{
              account_id: account.id,
              email: account.email
            })
            |> RenewCollabProj.ProjectCommander.run_project_command_sync()

            :ok

          {:error, :account, changeset, _} ->
            {:error, changeset}

          _ ->
            :error
        end

      _ ->
        :error
    end
  end

  defp create_parent_layer_ids(layer_ids, child_layer_id) do
    layer_ids
    |> List.wrap()
    |> Kernel.++([child_layer_id])
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end
end
