defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo
  alias RenewCollab.Commands

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Interface
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
        left_join: il in assoc(l, :outgoing_link),
        left_join: ol in assoc(l, :incoming_links),
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

    RenewCollab.SimpleCache.cache("document-#{id}", fn -> Repo.one(query) end, 600)
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
      attrs: attrs,
      parenthoods: parenthoods,
      hyperlinks: hyperlinks,
      bonds: bonds
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
        RenewCollab.SimpleCache.delete("document-#{document_id}")
        RenewCollab.SimpleCache.delete("document-undo-redo-#{document_id}")
        RenewCollab.SimpleCache.delete("document-versions-#{document_id}")

        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "document:deleted",
          %{"id" => document_id}
        )

        :ok
    end
  end

  def toggle_visible(document_id, layer_id) do
    # Update the record
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_visibility,
      fn %{document_id: document_id} ->
        from(
          l in Layer,
          where: l.id == ^layer_id and l.document_id == ^document_id,
          update: [set: [hidden: not l.hidden]]
        )
      end,
      []
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def run_document_transaction(multi) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          RenewCollab.SimpleCache.delete("document-#{document_id}")
          RenewCollab.SimpleCache.delete("document-undo-redo-#{document_id}")
          RenewCollab.SimpleCache.delete("document-versions-#{document_id}")

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )

          {:ok, values}
        end
    end
  end

  def layer_style_key("opacity"), do: :opacity
  def layer_style_key("background_color"), do: :background_color
  def layer_style_key("border_color"), do: :border_color
  def layer_style_key("border_width"), do: :border_width
  def layer_style_key("border_dash_array"), do: :border_dash_array

  def update_layer_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(:layer, from(l in Layer, where: l.id == ^layer_id))
    |> Ecto.Multi.insert(
      :style,
      fn %{layer: layer} ->
        Ecto.build_assoc(layer, :style)
        |> LayerStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def layer_edge_style_key("stroke_width"), do: :stroke_width
  def layer_edge_style_key("stroke_color"), do: :stroke_color
  def layer_edge_style_key("stroke_join"), do: :stroke_join
  def layer_edge_style_key("stroke_cap"), do: :stroke_cap
  def layer_edge_style_key("stroke_dash_array"), do: :stroke_dash_array
  def layer_edge_style_key("smoothness"), do: :smoothness
  def layer_edge_style_key("source_tip_symbol_shape_id"), do: :source_tip_symbol_shape_id
  def layer_edge_style_key("target_tip_symbol_shape_id"), do: :target_tip_symbol_shape_id

  def update_layer_edge_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: e in assoc(l, :edge), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{edge: edge} ->
        Ecto.build_assoc(edge, :style)
        |> EdgeStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def layer_text_style_key("italic"), do: :italic
  def layer_text_style_key("underline"), do: :underline
  def layer_text_style_key("alignment"), do: :alignment
  def layer_text_style_key("font_size"), do: :font_size
  def layer_text_style_key("font_family"), do: :font_family
  def layer_text_style_key("bold"), do: :bold
  def layer_text_style_key("text_color"), do: :text_color
  def layer_text_style_key("rich"), do: :rich
  def layer_text_style_key("blank_lines"), do: :blank_lines

  def update_layer_text_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: e in assoc(l, :text), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{text: text} ->
        Ecto.build_assoc(text, :style)
        |> TextStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_text_body(
        document_id,
        layer_id,
        new_body
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :body,
      fn %{text: text} ->
        Text.changeset(text, %{body: new_body})
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_box_size(
        document_id,
        layer_id,
        new_size
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        Box.change_size(box, new_size)
      end
    )
    |> Ecto.Multi.update_all(
      :update_linked_textes,
      fn %{box: %{position_x: old_x, position_y: old_y}} ->
        dx = Map.get(new_size, "position_x", old_x) - old_x
        dy = Map.get(new_size, "position_y", old_y) - old_y

        from(t in Text,
          update: [inc: [position_x: ^dx, position_y: ^dy]],
          where:
            t.layer_id in subquery(
              from(h in Hyperlink,
                select: h.source_layer_id,
                where: h.target_layer_id == ^layer_id
              )
            )
        )
      end,
      []
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{box: box} ->
        from(own_box in Box,
          join: own_layer in assoc(own_box, :layer),
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          join: layer in assoc(bond, :layer),
          join: box in assoc(layer, :box),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: own_box.id == ^box.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket,
            edge: edge,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_text_position(
        document_id,
        layer_id,
        new_position
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{text: text} ->
        Text.change_position(text, new_position)
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_z_index(
        document_id,
        layer_id,
        z_index
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      from(l in Layer, where: l.id == ^layer_id, select: l)
    )
    |> Ecto.Multi.update(
      :z_index,
      fn %{layer: layer} ->
        Layer.changeset(layer, %{
          z_index: z_index
        })
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_edge_position(
        document_id,
        layer_id,
        new_position
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :position,
      fn %{edge: edge} ->
        Edge.change_position(edge, new_position)
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{edge: edge} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^edge.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_edge_waypoint_position(
        document_id,
        layer_id,
        waypoint_id,
        new_position
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.update(
      :size,
      fn %{waypoint: waypoint} ->
        Waypoint.change_position(waypoint, new_position)
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^waypoint.edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def delete_layer_edge_waypoint(
        document_id,
        layer_id,
        waypoint_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.delete(
      :deletion,
      fn %{waypoint: waypoint} ->
        waypoint
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^waypoint.edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def remove_all_layer_edge_waypoints(
        document_id,
        layer_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.delete_all(
      :waypoint,
      fn
        %{edge: edge} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            select: w
          )
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{edge: edge} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^edge.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_semantic_tag(
        document_id,
        layer_id,
        new_tag
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      from(l in Layer, where: l.id == ^layer_id, select: l)
    )
    |> Ecto.Multi.update(
      :update,
      fn %{layer: layer} ->
        Ecto.Changeset.change(layer, semantic_tag: new_tag)
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_layer_box_shape(
        document_id,
        layer_id,
        shape_id,
        attributes
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        RenewCollab.Element.Box.changeset(box, %{
          symbol_shape_id: shape_id,
          symbol_shape_attributes: attributes
        })
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def create_layer_edge_waypoint(
        document_id,
        layer_id,
        prev_waypoint_id,
        position \\ nil
      ) do
    set_position =
      case position do
        {x, y} ->
          %{
            position_x: x,
            position_y: y
          }

        nil ->
          %{}
      end

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      if is_nil(prev_waypoint_id) do
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w2 in assoc(e, :waypoints),
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: e.id,
          limit: 1,
          select: {e, nil, w2, max(w3.sort)}
        )
      else
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w in assoc(e, :waypoints),
          on: w.id == ^prev_waypoint_id,
          left_join: w2 in assoc(e, :waypoints),
          on: w2.sort > w.sort,
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: e.id,
          limit: 1,
          select: {e, w, w2, max(w3.sort)}
        )
      end
    )
    |> Ecto.Multi.update_all(
      :increment_future_waypoints,
      fn
        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: 1 + ^max_sort * 2]]
          )

        %{edge: {edge, prev_waypoint_id, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint_id.sort,
            update: [inc: [sort: 1 + ^max_sort * 2]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :offset_waypoints,
      fn
        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: -(^max_sort) * 2]]
          )

        %{edge: {edge, prev_waypoint_id, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint_id.sort,
            update: [inc: [sort: -(^max_sort) * 2]]
          )
      end,
      []
    )
    |> Ecto.Multi.insert(
      :waypoint,
      fn
        %{edge: {edge, nil, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: (edge.source_x + edge.target_x) / 2,
            position_y: (edge.source_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: prev_waypoint.sort + 1,
            position_x: (prev_waypoint.position_x + edge.target_x) / 2,
            position_y: (prev_waypoint.position_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, nil, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + edge.source_x) / 2,
            position_y: (next_waypoint.position_y + edge.source_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + prev_waypoint.position_x) / 2,
            position_y: (next_waypoint.position_y + prev_waypoint.position_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^waypoint.edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def delete_layer(document_id, layer_id, delete_children \\ true) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(:child_layers, fn %{document_id: document_id} ->
      from(p in LayerParenthood,
        where:
          p.ancestor_id == ^layer_id and p.document_id == ^document_id and
            (p.depth == 0 or ^delete_children),
        select: p.descendant_id
      )
    end)
    |> Ecto.Multi.all(:connected_edge_layers, fn
      %{child_layers: child_layers} ->
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          where: b.layer_id in ^child_layers,
          select: e.layer_id
        )
    end)
    |> Ecto.Multi.all(:hyperlinked_layers, fn
      %{child_layers: child_layers, connected_edge_layers: edge_layers} ->
        from(h in Hyperlink,
          where: h.target_layer_id in ^child_layers or h.target_layer_id in ^edge_layers,
          select: h.source_layer_id
        )
    end)
    |> Ecto.Multi.delete_all(
      :delete_edges,
      fn %{
           document_id: document_id,
           connected_edge_layers: edge_layers,
           hyperlinked_layers: hyperlinked_layers
         } ->
        from(l in Layer,
          where:
            (l.id in ^edge_layers or l.id in ^hyperlinked_layers) and
              l.document_id == ^document_id
        )
      end,
      []
    )
    |> Ecto.Multi.delete_all(
      :delete_layer,
      fn %{document_id: document_id, child_layers: child_layers} ->
        from(l in Layer, where: l.id in ^child_layers and l.document_id == ^document_id)
      end,
      []
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def move_layer(
        document_id,
        layer_id,
        target_layer_id,
        {order, relative}
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(:conflict_count, fn _ ->
      from(p in LayerParenthood,
        where: p.ancestor_id == ^layer_id and p.descendant_id == ^target_layer_id,
        select: count(p.id)
      )
    end)
    |> Ecto.Multi.run(:check_conflict, fn
      _, %{conflict_count: 0} = changes -> {:ok, changes}
      _, %{conflict_count: c} when c > 0 -> {:error, :cyclic_hierarchy}
      _, changes -> {:error, changes}
    end)
    |> Ecto.Multi.one(:target, fn _ ->
      case relative do
        :inside ->
          from(parent in LayerParenthood,
            join: parent_layer in Layer,
            on: parent_layer.id == parent.descendant_id,
            left_join: sibling in LayerParenthood,
            on: sibling.depth == 1 and sibling.ancestor_id == parent.ancestor_id,
            left_join: sibling_layer in Layer,
            on: sibling.descendant_id == sibling_layer.id and sibling_layer.id != ^layer_id,
            where: parent.descendant_id == ^target_layer_id,
            where: parent.depth == 0,
            group_by: parent.ancestor_id,
            select: %{
              parent_id: parent.ancestor_id,
              z_index_above: max(sibling_layer.z_index) + 1,
              z_index_below: min(sibling_layer.z_index) - 1
            }
          )

        :outside ->
          from(target_layer in Layer,
            where: target_layer.id == ^target_layer_id,
            left_join: parent in LayerParenthood,
            on: parent.depth == 1 and parent.descendant_id == target_layer.id,
            select: %{
              parent_id: parent.ancestor_id,
              z_index_above: target_layer.z_index + 1,
              z_index_below: target_layer.z_index - 1
            }
          )
      end
    end)
    |> Ecto.Multi.all(:new_parents, fn
      %{target: %{parent_id: nil}} ->
        from(
          low in LayerParenthood,
          where: false
        )

      %{target: %{parent_id: target_parent_id}, document_id: document_id} ->
        # SELECT low.child_id,
        # high.parent_id, 
        # low.depth + high.depth + 1
        # FROM site_closure low, site_closure high
        # WHERE low.parent_id = 3 AND high.child_id=5;
        from(
          low in LayerParenthood,
          join: high in LayerParenthood,
          on: true,
          where: low.ancestor_id == ^layer_id,
          where: high.descendant_id == ^target_parent_id,
          select: %{
            document_id: ^document_id,
            descendant_id: low.descendant_id,
            ancestor_id: high.ancestor_id,
            depth: low.depth + high.depth + 1
          }
        )
    end)
    |> Ecto.Multi.delete_all(
      :delete_old_parents,
      fn
        # DELETE FROM site_closure WHERE id IN (
        # SELECT bad.id FROM site_closure ok 
        # LEFT JOIN site_closure bad ON bad.child_id=ok.child_id
        # WHERE ok.parent_id=3 and ok.depth < bad.depth
        # );

        _ ->
          from(p in LayerParenthood,
            where:
              p.id in subquery(
                from(ok in LayerParenthood,
                  left_join: bad in LayerParenthood,
                  on: bad.descendant_id == ok.descendant_id,
                  where: ok.ancestor_id == ^layer_id and ok.depth < bad.depth,
                  select: bad.id
                )
              )
          )
      end
    )
    |> Ecto.Multi.insert_all(
      :insert_new_parents,
      LayerParenthood,
      fn
        # INSERT INTO site_closure(child_id, parent_id, depth)
        # SELECT low.child_id,
        # high.parent_id, 
        # low.depth + high.depth + 1
        # FROM site_closure low, site_closure high
        # WHERE low.parent_id = 3 AND high.child_id=5;

        %{new_parents: new_parents} ->
          new_parents
          |> Enum.map(&Map.put(&1, :id, Ecto.UUID.generate()))
      end
    )
    |> Ecto.Multi.update_all(
      :update_z_Index,
      fn
        %{target: %{z_index_above: z_index_above, z_index_below: z_index_below}} ->
          new_z_index =
            case order do
              :below -> z_index_below
              :above -> z_index_above
            end
            |> then(&if(is_nil(&1), do: 0, else: &1))

          from(
            l in Layer,
            where: l.id == ^layer_id,
            update: [set: [z_index: ^new_z_index]]
          )
      end,
      []
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()

    # {:error, :check_conflict, :cyclic_hierarchy, _} ->
    #   {:error, :cyclic_hierarchy}
  end

  def parse_hierarchy_position("above", "inside"), do: {:above, :inside}
  def parse_hierarchy_position("above", "outside"), do: {:above, :outside}
  def parse_hierarchy_position("below", "outside"), do: {:below, :outside}
  def parse_hierarchy_position("below", "inside"), do: {:below, :inside}

  def move_layer_relative(
        document_id,
        layer_id,
        dx,
        dy
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(:child_layers, fn %{document_id: document_id} ->
      from(p in LayerParenthood,
        where: p.ancestor_id == ^layer_id and p.document_id == ^document_id,
        select: p.descendant_id
      )
    end)
    |> Ecto.Multi.all(:connected_edge_layers, fn
      %{child_layers: child_layers} ->
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          where: b.layer_id in ^child_layers,
          select: e.layer_id
        )
    end)
    |> Ecto.Multi.all(:hyperlinked_layers, fn
      %{child_layers: child_layers, connected_edge_layers: edge_layers} ->
        from(h in Hyperlink,
          where: h.target_layer_id in ^child_layers or h.target_layer_id in ^edge_layers,
          select: h.source_layer_id
        )
    end)
    |> Ecto.Multi.run(
      :combined_layer_ids,
      fn _,
         %{
           child_layers: child_layers,
           connected_edge_layers: connected_edge_layers,
           hyperlinked_layers: hyperlinked_layers
         } ->
        {:ok, Enum.concat([child_layers, connected_edge_layers, hyperlinked_layers])}
      end
    )
    |> Ecto.Multi.update_all(
      :update_boxes,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(b in Box,
            where: b.layer_id in ^combined_layer_ids,
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_textes,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(t in Text,
            where: t.layer_id in ^combined_layer_ids,
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_edges,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(e in Edge,
            where: e.layer_id in ^combined_layer_ids,
            update: [inc: [source_x: ^dx, source_y: ^dy, target_x: ^dx, target_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_waypoints,
      fn
        %{child_layers: child_layers} ->
          from(w in Waypoint,
            where:
              w.edge_id in subquery(
                from(e in Edge, select: e.id, where: e.layer_id in ^child_layers)
              ),
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{combined_layer_ids: combined_layer_ids} ->
        from(own_box in Box,
          join: own_layer in assoc(own_box, :layer),
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          join: layer in assoc(bond, :layer),
          join: box in assoc(layer, :box),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: own_layer.id in ^combined_layer_ids or edge.layer_id in ^combined_layer_ids,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket,
            edge: edge,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def create_layer(document_id, attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert(
      :layer,
      fn %{document_id: document_id} ->
        %Layer{document_id: document_id}
        |> Layer.changeset(%{
          z_index: 0,
          semantic_tag: nil,
          hidden: false
        })
        |> Layer.changeset(attrs)
      end
    )
    |> Ecto.Multi.insert(
      :parenthood,
      fn %{layer: layer, document_id: document_id} ->
        %LayerParenthood{}
        |> LayerParenthood.changeset(%{
          document_id: document_id,
          ancestor_id: layer.id,
          descendant_id: layer.id,
          depth: 0
        })
      end
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{layer: layer} ->
        from(edge in Edge,
          join: bond in assoc(edge, :bonds),
          join: layer in assoc(bond, :layer),
          join: box in assoc(layer, :box),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: edge.layer_id == ^layer.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket,
            edge: edge,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def detach_bond(document_id, bond_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(:bond, fn %{document_id: document_id} ->
      from(b in Bond,
        join: e in assoc(b, :element_edge),
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id and b.id == ^bond_id
      )
    end)
    |> Ecto.Multi.delete(:delete_bond, fn %{bond: bond} ->
      bond
    end)
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def create_edge_bond(
        document_id,
        edge_id,
        kind,
        layer_id,
        socket_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert(
      :new_bond,
      %Bond{}
      |> Bond.changeset(%{
        element_edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      })
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{new_bond: bond} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^bond.element_edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def unlink_layer(
        document_id,
        layer_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :hyperlink,
      fn %{document_id: document_id} ->
        from(h in Hyperlink,
          join: s in assoc(h, :source_layer),
          where: s.id == ^layer_id and s.document_id == ^document_id
        )
      end
    )
    |> Ecto.Multi.delete(
      :delete_ink,
      fn %{hyperlink: hyperlink} ->
        hyperlink
      end
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def link_layer(
        document_id,
        layer_id,
        target_layer_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      fn %{document_id: document_id} ->
        from(s in Layer,
          where: s.id == ^layer_id and s.document_id == ^document_id
        )
      end
    )
    |> Ecto.Multi.insert(:insert_hyperlink, fn %{layer: layer} ->
      %Hyperlink{}
      |> Hyperlink.changeset(%{
        source_layer_id: layer.id,
        target_layer_id: target_layer_id
      })
    end)
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def assign_layer_socket_schema(
        document_id,
        layer_id,
        socket_schema_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      fn %{document_id: document_id} ->
        from(s in Layer,
          where: s.id == ^layer_id and s.document_id == ^document_id
        )
      end
    )
    |> Ecto.Multi.insert(
      :insert_interface,
      fn %{layer: layer} ->
        %Interface{}
        |> Interface.changeset(%{
          layer_id: layer.id,
          socket_schema_id: socket_schema_id
        })
      end,
      on_conflict: {:replace, [:socket_schema_id]}
    )
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def remove_layer_socket_schema(
        document_id,
        layer_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :interface,
      fn %{document_id: document_id} ->
        from(s in Layer,
          join: i in assoc(s, :interface),
          where: s.id == ^layer_id and s.document_id == ^document_id,
          select: i
        )
      end
    )
    |> Ecto.Multi.delete(:insert_interface, fn %{interface: interface} ->
      interface
    end)
    |> Ecto.Multi.append(Versioning.snapshot_multi())
    |> run_document_transaction()
  end

  def update_document_meta(document_id, meta) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update(:update_meta, fn %{document_id: document_id} ->
      %Document{id: document_id} |> Document.changeset(meta)
    end)
    |> run_document_transaction()
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
