defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo
  alias RenewCollab.Commands

  alias RenewCollab.Document.Document
  alias RenewCollab.Document.TransientDocument
  alias RenewCollab.Versioning

  def list_documents do
    RenewCollab.SimpleCache.cache(
      :all_documents,
      fn ->
        Repo.all(from(Document, order_by: [desc: :inserted_at, desc: :updated_at]))
      end,
      600
    )
  end

  def count_documents do
    Repo.one(from(d in Document, select: count(d.id)))
  end

  def get_document(id), do: Repo.get(Document, id)

  def get_document_with_elements(id) do
    query =
      from(d in Document,
        where: d.id == ^id,
        left_join: l in assoc(d, :layers),
        left_join: dp in assoc(l, :direct_parent),
        left_join: b in assoc(l, :box),
        left_join: ss in assoc(b, :symbol_shape),
        left_join: t in assoc(l, :text),
        left_join: e in assoc(l, :edge),
        left_join: sb in assoc(e, :source_bond),
        left_join: tb in assoc(e, :target_bond),
        left_join: w in assoc(e, :waypoints),
        left_join: ls in assoc(l, :style),
        left_join: ts in assoc(t, :style),
        left_join: es in assoc(e, :style),
        left_join: i in assoc(l, :interface),
        left_join: ol in assoc(l, :outgoing_link),
        left_join: il in assoc(l, :incoming_links),
        order_by: [asc: l.z_index, asc: w.sort],
        preload: [
          layers:
            {l,
             [
               direct_parent: dp,
               box: {b, [symbol_shape: ss]},
               text: {t, [style: ts]},
               edge: {e, [style: es, waypoints: w, source_bond: sb, target_bond: tb]},
               style: ls,
               interface: i,
               outgoing_link: ol,
               incoming_links: il
             ]}
        ]
      )

    RenewCollab.SimpleCache.cache({:document, id}, fn -> Repo.one(query) end, 600)
  end

  def run_document_transaction(multi) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          RenewCollab.SimpleCache.delete({:document, document_id})
          RenewCollab.SimpleCache.delete({:undo_redo, document_id})
          RenewCollab.SimpleCache.delete({:versions, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_missing, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_invalids, document_id})

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )

          {:ok, values}
        end
    end
  end

  def run_document_command(command, snapshot \\ true)

  def run_document_command(%{__struct__: module} = command, snapshot) do
    apply(module, :multi, [command])
    |> then(&if(snapshot, do: Ecto.Multi.append(&1, Versioning.snapshot_multi()), else: &1))
    |> run_document_transaction()
  end

  def insert_into_document(target_document_id, source_document_id) do
    Commands.InsertDocument.new(%{
      target_document_id: target_document_id,
      source_document_id: source_document_id
    })
    |> run_document_command()
  end

  def create_document(attrs \\ %{}, parenthoods \\ [], hyperlinks \\ [], bonds \\ []) do
    Commands.CreateDocument.new(%{
      doc: %TransientDocument{
        content: attrs,
        parenthoods: parenthoods,
        hyperlinks: hyperlinks,
        bonds: bonds
      }
    })
    |> run_document_command()
    |> case do
      {:ok, %{insert_document: inserted_document}} ->
        RenewCollab.SimpleCache.delete(:all_documents)

        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "documents:new",
          {"document:new", inserted_document.id}
        )

        {:ok, inserted_document}
    end
  end

  def duplicate_document(document_id) do
    Commands.DuplicateDocument.new(%{
      document_id: document_id
    })
    |> run_document_command()
    |> case do
      {:ok, %{insert_document: inserted_document}} ->
        RenewCollab.SimpleCache.delete(:all_documents)

        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "documents:new",
          {"document:new", inserted_document.id}
        )

        {:ok, inserted_document}
    end
  end

  def delete_document(document_id) do
    Commands.DeleteDocument.new(%{
      document_id: document_id
    })
    |> run_document_command(false)
    |> case do
      {:ok, %{document_id: document_id}} ->
        RenewCollab.SimpleCache.delete(:all_documents)
        RenewCollab.SimpleCache.delete({:document, document_id})
        RenewCollab.SimpleCache.delete({:undo_redo, document_id})
        RenewCollab.SimpleCache.delete({:versions, document_id})
        RenewCollab.SimpleCache.delete({:hierarchy_missing, document_id})
        RenewCollab.SimpleCache.delete({:hierarchy_invalids, document_id})

        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "document:deleted",
          %{"id" => document_id}
        )

        :ok
    end
  end

  def toggle_visible(document_id, layer_id) do
    Commands.ToggleVisible.new(%{document_id: document_id, layer_id: layer_id})
    |> run_document_command()
  end

  def update_layer_style(document_id, layer_id, style_attr, value) do
    Commands.UpdateLayerStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> run_document_command()
  end

  def update_layer_edge_style(document_id, layer_id, style_attr, value) do
    Commands.UpdateLayerEdgeStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> run_document_command()
  end

  def update_layer_text_style(document_id, layer_id, style_attr, value) do
    Commands.UpdateLayerTextStyle.new(%{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> run_document_command()
  end

  def update_layer_text_body(
        document_id,
        layer_id,
        new_body
      ) do
    Commands.UpdateLayerTextBody.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_body: new_body
    })
    |> run_document_command()
  end

  def update_layer_box_size(
        document_id,
        layer_id,
        new_size
      ) do
    Commands.UpdateLayerBoxSize.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_size: new_size
    })
    |> run_document_command()
  end

  def update_layer_text_position(
        document_id,
        layer_id,
        new_position
      ) do
    Commands.UpdateLayerTextPosition.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> run_document_command()
  end

  def update_layer_z_index(
        document_id,
        layer_id,
        z_index
      ) do
    Commands.UpdateLayerZIndex.new(%{
      document_id: document_id,
      layer_id: layer_id,
      z_index: z_index
    })
    |> run_document_command()
  end

  def update_layer_edge_position(
        document_id,
        layer_id,
        new_position
      ) do
    Commands.UpdateLayerEdgePosition.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> run_document_command()
  end

  def update_layer_edge_waypoint_position(
        document_id,
        layer_id,
        waypoint_id,
        new_position
      ) do
    Commands.UpdateLayerEdgeWaypointPosition.new(%{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: new_position
    })
    |> run_document_command()
  end

  def delete_layer_edge_waypoint(
        document_id,
        layer_id,
        waypoint_id
      ) do
    Commands.DeleteLayerEdgeWaypoint.new(%{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    })
    |> run_document_command()
  end

  def remove_all_layer_edge_waypoints(
        document_id,
        layer_id
      ) do
    Commands.RemoveAllLayerEdgeWaypoints.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> run_document_command()
  end

  def update_layer_semantic_tag(
        document_id,
        layer_id,
        new_tag
      ) do
    Commands.UpdateLayerSemanticTag.new(%{
      document_id: document_id,
      layer_id: layer_id,
      new_tag: new_tag
    })
    |> run_document_command()
  end

  def update_layer_box_shape(
        document_id,
        layer_id,
        shape_id,
        attributes
      ) do
    Commands.UpdateLayerBoxShape.new(%{
      document_id: document_id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: attributes
    })
    |> run_document_command()
  end

  def create_layer_edge_waypoint(
        document_id,
        layer_id,
        prev_waypoint_id,
        position \\ nil
      ) do
    Commands.CreateLayerEdgeWaypoint.new(%{
      document_id: document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: position
    })
    |> run_document_command()
  end

  def delete_layer(document_id, layer_id, delete_children \\ true) do
    Commands.DeleteLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      delete_children: delete_children
    })
    |> run_document_command()
  end

  def move_layer(
        document_id,
        layer_id,
        target_layer_id,
        {order, relative}
      ) do
    RenewCollab.Commands.MoveLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: {order, relative}
    })
    |> run_document_command()
  end

  def move_layer_relative(
        document_id,
        layer_id,
        dx,
        dy
      ) do
    Commands.MoveLayerRelative.new(%{
      document_id: document_id,
      layer_id: layer_id,
      dx: dx,
      dy: dy
    })
    |> run_document_command()
  end

  def create_layer(document_id, attrs \\ %{}) do
    Commands.CreateLayer.new(%{
      document_id: document_id,
      attrs: attrs
    })
    |> run_document_command()
  end

  def detach_bond(document_id, bond_id) do
    Commands.DeleteBond.new(%{
      document_id: document_id,
      bond_id: bond_id
    })
    |> run_document_command()
  end

  def create_edge_bond(
        document_id,
        edge_id,
        kind,
        layer_id,
        socket_id
      ) do
    Commands.CreateEdgeBond.new(%{
      document_id: document_id,
      edge_id: edge_id,
      kind: kind,
      layer_id: layer_id,
      socket_id: socket_id
    })
    |> run_document_command()
  end

  def unlink_layer(
        document_id,
        layer_id
      ) do
    Commands.UnlinkLayer.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> run_document_command()
  end

  def link_layer(
        document_id,
        layer_id,
        target_layer_id
      ) do
    Commands.LinkLayer.new(%{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    })
    |> run_document_command()
  end

  def assign_layer_socket_schema(
        document_id,
        layer_id,
        socket_schema_id
      ) do
    Commands.AssignLayerSocketSchema.new(%{
      document_id: document_id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    })
    |> run_document_command()
  end

  def remove_layer_socket_schema(
        document_id,
        layer_id
      ) do
    Commands.RemoveLayerSocketSchema.new(%{
      document_id: document_id,
      layer_id: layer_id
    })
    |> run_document_command()
  end

  def update_document_meta(document_id, meta) do
    Commands.UpdateDocumentMeta.new(%{document_id: document_id, meta: meta})
    |> run_document_command()
    |> case do
      {:ok, %{document_id: document_id}} ->
        RenewCollab.SimpleCache.delete(:all_documents)

        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "document:renamed",
          %{"id" => document_id}
        )
    end
  end
end
