defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text

  def reset do
    Repo.delete_all(Document)

    %SocketSchema{}
    |> SocketSchema.changeset(%{
      name: "simple-socket-schema",
      sockets: [
        %{
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        }
      ]
    })
    |> Repo.insert()
  end

  def list_documents do
    Repo.all(Document, order_by: [asc: :inserted_at])
  end

  def get_document!(id), do: Repo.get!(Document, id)

  def get_document_with_elements!(id),
    do:
      Repo.get!(Document, id)
      |> Repo.preload(
        layers:
          from(e in Layer,
            order_by: [asc: :z_index],
            preload: [
              direct_parent: [],
              box: [
                symbol_shape: []
              ],
              text: [style: []],
              edge: [
                waypoints: ^from(w in Waypoint, order_by: [asc: :sort]),
                style: []
              ],
              style: [],
              interface: [],
              outgoing_link: [],
              incoming_links: []
            ]
          )
      )

  def deep_clone_document!(id) do
    Repo.transaction(fn ->
      doc = get_document_with_elements!(id)

      new_layers_ids =
        doc.layers
        |> Enum.map(fn layer -> {layer.id, Ecto.UUID.generate()} end)
        |> Map.new()

      document_data =
        doc
        |> strip_id
        |> Map.update(:layers, [], fn layers ->
          layers
          |> Enum.map(fn layer ->
            layer
            |> Map.from_struct()
            |> Map.update(:id, nil, &Map.get(new_layers_ids, &1))
            |> Map.update(:box, nil, &strip_id/1)
            |> Map.update(:box, nil, &strip_fk(&1, :layer_id))
            |> Map.update(:text, nil, &strip_id(&1, [:style]))
            |> Map.update(:text, nil, &strip_fk(&1, :layer_id))
            |> Map.update(:edge, nil, &strip_id(&1, [:style]))
            |> Map.update(:edge, nil, &strip_fk(&1, :layer_id))
            |> Map.update(:edge, nil, fn
              nil ->
                nil

              edge ->
                %{
                  edge
                  | waypoints:
                      edge.waypoints |> strip_id() |> Enum.map(&Map.delete(&1, :edge_id)),
                    source_bond: nil,
                    target_bond: nil
                }
            end)
            |> Map.update(:style, nil, &strip_id/1)
            |> Map.update(:style, nil, &strip_fk(&1, :layer_id))
          end)
        end)

      new_parenthoods =
        from(p in LayerParenthood, where: p.document_id == ^id, select: p)
        |> Repo.all()
        |> Enum.map(fn %{depth: d, ancestor_id: anc, descendant_id: dec} ->
          {
            Map.get(new_layers_ids, anc),
            Map.get(new_layers_ids, dec),
            d
          }
        end)

      hyperlinks =
        from(h in Hyperlink,
          join: s in assoc(h, :source_layer),
          join: t in assoc(h, :target_layer),
          where: s.document_id == ^id and t.document_id == ^id,
          select: h
        )
        |> Repo.all()
        |> Enum.map(fn hyperlink ->
          Map.new()
          |> Map.put(:source_layer_id, Map.get(new_layers_ids, hyperlink.source_layer_id))
          |> Map.put(:target_layer_id, Map.get(new_layers_ids, hyperlink.target_layer_id))
        end)

      new_bonds =
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          join: l in assoc(e, :layer),
          where: l.document_id == ^id,
          select: %{
            edge_layer_id: l.id,
            layer_id: b.layer_id,
            socket_id: b.socket_id,
            kind: b.kind
          }
        )
        |> Repo.all()
        |> Enum.map(fn bond ->
          bond
          |> Map.update(:edge_layer_id, nil, &Map.get(new_layers_ids, &1))
          |> Map.update(:layer_id, nil, &Map.get(new_layers_ids, &1))
        end)

      {document_data, new_parenthoods, hyperlinks, new_bonds}
    end)
  end

  def duplicate_document(id) do
    {:ok, {doc_params, parenthoods, hyperlinks, bonds}} = deep_clone_document!(id)

    create_document(
      doc_params
      |> Map.update(:name, "Untitled", &"#{String.trim_trailing(&1, "(Copy)")} (Copy)"),
      parenthoods,
      hyperlinks,
      bonds
    )
  end

  defp strip_id(struct, path \\ [])

  defp strip_id(%{} = struct, []) do
    struct
    |> Map.from_struct()
    |> Map.delete(:id)
  end

  defp strip_id(%{} = struct, [key | rest]) do
    struct
    |> Map.from_struct()
    |> Map.delete(:id)
    |> Map.update(key, nil, &strip_id(&1, rest))
  end

  defp strip_id([_ | _] = list, keys) do
    Enum.map(list, &strip_id(&1, keys))
  end

  defp strip_id([] = list, _), do: list
  defp strip_id(nil, _), do: nil

  defp strip_fk(%{} = map, fkid) do
    map
    |> Map.delete(fkid)
  end

  defp strip_fk(nil, fkid) do
    nil
  end

  def create_document(attrs \\ %{}, parenthoods \\ [], hyperlinks \\ [], bonds \\ []) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :insert_document,
      %Document{} |> Document.changeset(attrs)
    )
    |> Ecto.Multi.insert_all(
      :insert_parenthoods,
      LayerParenthood,
      fn %{insert_document: new_document} ->
        Enum.map(
          parenthoods,
          fn {ancestor_id, descendant_id, depth} ->
            %{
              depth: depth,
              ancestor_id: ancestor_id,
              descendant_id: descendant_id,
              document_id: new_document.id
            }
          end
        )
      end,
      on_conflict: {:replace, [:depth, :ancestor_id, :descendant_id]}
    )
    |> Ecto.Multi.insert_all(
      :insert_hyperlinks,
      Hyperlink,
      fn _ ->
        hyperlinks
        |> Enum.map(fn %{
                         source_layer_id: source_layer_id,
                         target_layer_id: target_layer_id
                       } ->
          %{
            source_layer_id: source_layer_id,
            target_layer_id: target_layer_id,
            inserted_at: now,
            updated_at: now
          }
        end)
      end
    )
    |> Ecto.Multi.all(
      :layer_edge_ids,
      fn %{insert_document: new_document} ->
        from(e in Edge,
          join: l in assoc(e, :layer),
          where: l.document_id == ^new_document.id,
          select: {l.id, e.id}
        )
      end
    )
    |> then(fn multi ->
      bonds
      |> Enum.chunk_every(500)
      |> Enum.with_index()
      |> Enum.reduce(multi, fn {bond_chunk, chunk_index}, multi ->
        Ecto.Multi.insert_all(
          multi,
          :"insert_bonds_#{chunk_index}",
          Bond,
          fn %{layer_edge_ids: layer_edge_ids} ->
            layer_edge_map = Map.new(layer_edge_ids)

            bond_chunk
            |> Enum.map(fn
              %{
                edge_layer_id: edge_layer_id,
                layer_id: layer_id,
                socket_id: socket_id,
                kind: kind
              } ->
                %{
                  element_edge_id: Map.get(layer_edge_map, edge_layer_id),
                  layer_id: layer_id,
                  socket_id: socket_id,
                  kind: kind,
                  inserted_at: now,
                  updated_at: now
                }
            end)
          end
        )
      end)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_document: inserted_document}} ->
        RenewCollabWeb.Endpoint.broadcast!(
          "documents",
          "documents:new",
          {"document:new", inserted_document.id}
        )

        {:ok, inserted_document}

      e ->
        dbg(e)
    end
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)

    RenewCollabWeb.Endpoint.broadcast!(
      "documents",
      "document:deleted",
      %{"id" => document.id}
    )
  end

  def create_element(%Document{} = document, attrs \\ %{}) do
    {:ok, %{insert_layer: layer}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :insert_layer,
        Layer.changeset(%Layer{document_id: document.id}, attrs)
      )
      |> Ecto.Multi.insert(
        :insert_parenthood,
        fn %{insert_layer: new_layer} ->
          LayerParenthood.changeset(%LayerParenthood{}, %{
            depth: 0,
            document_id: new_layer.document_id,
            ancestor_id: new_layer.id,
            descendant_id: new_layer.id
          })
        end
      )
      |> Repo.transaction()

    {:ok, layer}
  end

  def get_element!(document, id) do
    Repo.get_by(Layer, id: id, document: document)
    |> Repo.preload(
      box: [
        symbol_shape: []
      ],
      text: [style: []],
      edge: [
        waypoints: from(w in Waypoint, order_by: [asc: :sort]),
        style: []
      ],
      style: []
    )
  end

  def toggle_visible(document_id, layer_id) do
    query =
      from(
        l in Layer,
        where: l.id == ^layer_id and l.document_id == ^document_id,
        update: [set: [hidden: not l.hidden]]
      )

    # Update the record
    Repo.update_all(query, [])
    |> case do
      {1, nil} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def layer_style_key("opacity"), do: :opacity
  def layer_style_key("background_color"), do: :background_color
  def layer_style_key("border_color"), do: :border_color
  def layer_style_key("border_width"), do: :border_width
  def layer_style_key("border_dash_array"), do: :border_dash_array

  def update_layer_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:layer, from(l in Layer, where: l.id == ^layer_id))
    |> Ecto.Multi.insert(
      :style,
      fn %{layer: layer} ->
        Ecto.build_assoc(layer, :style)
        |> LayerStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_text_body(
        document_id,
        layer_id,
        new_body
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_box_size(
        document_id,
        layer_id,
        new_size
      ) do
    Ecto.Multi.new()
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
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{box: box} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: edge in assoc(bond, :element_edge),
          join: box in assoc(l, :box),
          join: socket in assoc(bond, :socket),
          where: box.id == ^box.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket,
            edge: edge
          }
        )
      end
    )
    |> Ecto.Multi.all(
      :affected_waypoints,
      fn %{affected_bonds: affected_bonds} ->
        from(w in Waypoint,
          where: w.edge_id in ^Enum.map(affected_bonds, & &1.bond.element_edge_id),
          order_by: [asc: w.sort]
        )
      end
    )
    |> Ecto.Multi.run(:update_edge_points, fn repo,
                                              %{
                                                affected_bonds: affected_bonds,
                                                box: box,
                                                affected_waypoints: affected_waypoints
                                              } ->
      waypoint_map = Enum.group_by(affected_waypoints, & &1.edge_id) |> Map.new()

      affected_bonds
      |> Enum.reduce_while({:ok, []}, fn %{
                                           bond: bond,
                                           box: box,
                                           edge: edge,
                                           socket: socket
                                         },
                                         {:ok, acc} ->
        waypoints = Map.get(waypoint_map, bond.element_edge_id, [])

        first_waypoint =
          List.first(waypoints, %{position_x: edge.source_x, position_y: edge.source_y})

        last_waypoint =
          List.last(waypoints, %{position_x: edge.target_x, position_y: edge.target_y})

        target_x = box.position_x + box.width / 2
        target_y = box.position_y + box.height / 2

        offset_x = 10
        offset_y = 10

        case bond.kind do
          :source ->
            Edge.change_position(%Edge{id: bond.element_edge_id}, %{
              source_x: target_x + offset_x,
              source_y: target_y + offset_y
            })

          :target ->
            Edge.change_position(%Edge{id: bond.element_edge_id}, %{
              target_x: target_x + offset_x,
              target_y: target_y + offset_y
            })
        end
        |> Repo.update()
        |> case do
          {:ok, r} -> {:cont, {:ok, [r | acc]}}
          e -> {:halt, {e}}
        end
      end)
    end)
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_text_position(
        document_id,
        layer_id,
        new_position
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_z_index(
        document_id,
        layer_id,
        z_index
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_edge_position(
        document_id,
        layer_id,
        new_position
      ) do
    Ecto.Multi.new()
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
          join: socket in assoc(bond, :socket),
          where: bond.element_edge_id == ^edge.id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket
          }
        )
      end
    )
    |> Ecto.Multi.run(:update_edge_points, fn repo, %{affected_bonds: affected_bonds} ->
      affected_bonds
      |> Enum.reduce_while({:ok, []}, fn %{bond: bond, box: box, socket: socket}, {:ok, acc} ->
        case bond.kind do
          :source ->
            Edge.change_position(%Edge{id: bond.element_edge_id}, %{
              source_x: box.position_x + box.width / 2,
              source_y: box.position_y + box.height / 2
            })

          :target ->
            Edge.change_position(%Edge{id: bond.element_edge_id}, %{
              target_x: box.position_x + box.width / 2,
              target_y: box.position_y + box.height / 2
            })
        end
        |> Repo.update()
        |> case do
          {:ok, r} -> {:cont, {:ok, [r | acc]}}
          e -> {:halt, {e}}
        end
      end)
    end)
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_edge_waypoint_position(
        document_id,
        layer_id,
        waypoint_id,
        new_position
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def delete_layer_edge_waypoint(
        document_id,
        layer_id,
        waypoint_id
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def remove_all_layer_edge_waypoints(
        document_id,
        layer_id
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_semantic_tag(
        document_id,
        layer_id,
        new_tag
      ) do
    Ecto.Multi.new()
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def update_layer_box_shape(
        document_id,
        layer_id,
        shape_id,
        attributes
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        dbg(shape_id)

        RenewCollab.Element.Box.changeset(box, %{
          symbol_shape_id: shape_id,
          symbol_shape_attributes: attributes
        })
      end
    )
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
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
      :insert,
      fn
        %{edge: {edge, nil, nil, max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: (edge.source_x + edge.target_x) / 2,
            position_y: (edge.source_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, nil, max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: prev_waypoint.sort + 1,
            position_x: (prev_waypoint.position_x + edge.target_x) / 2,
            position_y: (prev_waypoint.position_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, nil, next_waypoint, max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + edge.source_x) / 2,
            position_y: (next_waypoint.position_y + edge.source_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, next_waypoint, max_sort}} ->
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
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def delete_layer(document_id, layer_id, delete_children \\ true) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:child_layers, fn _ ->
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
      fn %{connected_edge_layers: edge_layers, hyperlinked_layers: hyperlinked_layers} ->
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
      fn %{child_layers: child_layers} ->
        from(l in Layer, where: l.id in ^child_layers and l.document_id == ^document_id)
      end,
      []
    )
    |> Repo.transaction()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "redux_document:#{document_id}",
      {:document_changed, document_id}
    )
  end

  def move_layer(
        document_id,
        layer_id,
        target_layer_id,
        target
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:conflict_count, fn _ ->
      from(p in LayerParenthood,
        where: p.ancestor_id == ^layer_id and p.descendant_id == ^target_layer_id,
        select: count(p.id)
      )
    end)
    |> Ecto.Multi.run(:check_conflict, fn
      _, %{conflict_count: 0} = changes -> {:ok, changes}
      _, changes -> {:error, changes}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
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
    |> Ecto.Multi.all(:child_layers, fn _ ->
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
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end
end
