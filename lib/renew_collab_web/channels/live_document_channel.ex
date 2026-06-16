defmodule RenewCollabWeb.LiveDocumentChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views

  @impl true
  def init("live:document:" <> document_id, _params, socket) do
    case %Views.DocumentWithContent{
           document_id: document_id
         }
         |> Fetcher.fetch_as(socket.assigns.current_account) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-document:#{document_id}")

        account_id = socket.assigns.current_account.id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: nil,
          selection: []
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok, RenewCollabWeb.DocumentJSON.show_content(doc),
         %{:document_id => document_id, :account => socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message({:document_modified, document_id}, _state, %{
        :document_id => document_id,
        :account => account
      }) do
    %Views.DocumentWithContent{
      document_id: document_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        :stop

      doc ->
        {:noreply, RenewCollabWeb.DocumentJSON.show_content(doc)}
    end
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("cursor", %{"x" => x, "y" => y}, _state, _scope, socket) do
    account_id = socket.assigns.current_account.id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        cursor: %{x: x, y: y}
      })
    )

    :silent
  end

  @impl true
  def handle_event("cursor", %{}, _state, _scope, socket) do
    account_id = socket.assigns.current_account.id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        cursor: nil
      })
    )

    :silent
  end

  @impl true
  def handle_event("select", selection, _state, _scope, socket) do
    account_id = socket.assigns.current_account.id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: normalize_selection(selection)
      })
    )

    :silent
  end

  @impl true
  def handle_event(
        "restore_snapshot",
        snapshot_id,
        _state,
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(snapshot_id) do
    %Actions.DocumentSnapshotRestore{
      document_id: document_id,
      snapshot_id: snapshot_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "delete_layer",
        %{"layer_ids" => layer_ids} = params,
        _state,
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    if layer_ids != [] do
      %Actions.DocumentEditDeleteLayer{
        document_id: document_id,
        layer_ids: layer_ids,
        delete_children: Map.get(params, "delete_children", true)
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "create_layer",
        %{
          "pos" => %{"x" => cx, "y" => cy},
          "shape_id" => shape_id,
          "with_edge" => with_edge
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    {default_width, default_height} = default_box_size(params)
    width = Map.get(params, "width", default_width)
    height = Map.get(params, "height", default_height)

    %Actions.DocumentEditCreateLayerWithEdge{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      edge: with_edge,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", nil),
        "box" => %{
          "position_x" => cx - width / 2,
          "position_y" => cy - height / 2,
          "width" => width,
          "height" => height,
          "symbol_shape_id" => shape_id,
          "symbol_shape_attributes" => Map.get(params, "shape_attributes", nil)
        },
        "style" => Map.get(params, "style", nil),
        "interface" =>
          case Map.get(params, "socket_schema_id", nil) do
            nil ->
              nil

            id ->
              %{
                "socket_schema_id" => id
              }
          end,
        "outgoing_link" => outgoing_link_attrs(params)
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer, edge_layer: edge_layer}} ->
        {:reply, %{id: layer.id, target_layer_id: layer.id, edge_layer_id: edge_layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{"pos" => %{"x" => cx, "y" => cy}, "shape_id" => shape_id} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    {default_width, default_height} = default_box_size(params)
    width = Map.get(params, "width", default_width)
    height = Map.get(params, "height", default_height)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", nil),
        "box" => %{
          "position_x" => cx - width / 2,
          "position_y" => cy - height / 2,
          "width" => width,
          "height" => height,
          "symbol_shape_id" => shape_id,
          "symbol_shape_attributes" => Map.get(params, "shape_attributes", nil)
        },
        "style" => Map.get(params, "style", nil),
        "interface" =>
          case Map.get(params, "socket_schema_id", nil) do
            nil ->
              nil

            id ->
              %{
                "socket_schema_id" => id
              }
          end,
        "outgoing_link" => outgoing_link_attrs(params)
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{
          "pos" => %{"x" => x, "y" => y, "width" => width, "height" => height},
          "image" => background_url
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.ImageFigure",
        "box" => %{
          "position_x" => x,
          "position_y" => y,
          "width" => width,
          "height" => height
        },
        "style" => %{
          "background_url" => background_url,
          "border_width" => 0
        }
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{"points" => points} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_list(points) and length(points) > 1 do
    %{"x" => source_x, "y" => source_y} = Enum.at(points, 0)
    %{"x" => target_x, "y" => target_y} = Enum.at(points, -1)
    cyclic = Map.get(params, "cyclic", false)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.PolyLineFigure"),
        "style" => polygon_layer_style(params, cyclic),
        "edge" => %{
          "source_x" => source_x,
          "source_y" => source_y,
          "target_x" => target_x,
          "target_y" => target_y,
          "cyclic" => cyclic,
          "style" => Map.get(params, "style", nil),
          "waypoints" =>
            points
            |> Enum.drop(1)
            |> Enum.drop(-1)
            |> Enum.with_index()
            |> Enum.map(fn {%{"x" => x, "y" => y}, sort} ->
              %{
                position_x: x,
                position_y: y,
                sort: sort
              }
            end)
        }
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{"pos" => %{"x" => position_x, "y" => position_y}, "body" => body} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.TextFigure"),
        "text" => %{
          "position_x" => position_x,
          "position_y" => position_y,
          "body" => body,
          "renew_type" => Map.get(params, "renew_type", nil),
          "style" => Map.get(params, "style", nil)
        },
        "outgoing_link" =>
          case Map.get(params, "hyperlink", nil) do
            nil ->
              nil

            target_id ->
              %{
                "target_layer_id" => target_id
              }
          end
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{
          "source" => %{"socket_id" => source_socket_id, "layer_id" => source_layer_id},
          "target" => %{"socket_id" => target_socket_id, "layer_id" => target_layer_id}
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "de.renew.gui.ArcConnection"),
        "edge" => %{
          "source_x" => 0,
          "source_y" => 0,
          "target_x" => 0,
          "target_y" => 0,
          "source_bond" => %{
            "layer_id" => source_layer_id,
            "socket_id" => source_socket_id
          },
          "target_bond" => %{
            "layer_id" => target_layer_id,
            "socket_id" => target_socket_id
          },
          "style" => edge_style_attrs(params),
          "waypoints" => edge_waypoint_attrs(params)
        }
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{
          "layer_ids" => layer_ids
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    if layer_ids == [] do
      {:reply, %{id: nil}}
    else
      %Actions.DocumentEditCreateParentLayer{
        layer_ids: layer_ids,
        document_id: document_id,
        attrs: %{
          "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.GroupFigure")
        }
      }
      |> Dispatcher.perform_as(account)
      |> case do
        {:ok, %{layer: layer}} -> {:reply, %{id: layer.id}}
      end
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        %{
          "child_layer_id" => child_layer_id
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditCreateParentLayer{
      child_layer_id: child_layer_id,
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.GroupFigure")
      }
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}}
    end
  end

  @impl true
  def handle_event(
        "insert_document",
        %{
          "document_id" => source_document_id,
          "position" => %{"x" => x, "y" => y}
        },
        %{},
        %{:document_id => target_document_id, :account => account},
        socket
      ) do
    %Actions.DocumentEditInsertDocument{
      target_document_id: target_document_id,
      source_document_id: source_document_id,
      position: {x, y}
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer_ids: layer_ids}} -> reply_with_selection(socket, layer_ids)
      :ok -> :ack
      {:error, reason} -> {:reply, %{error: inspect(reason)}}
      _ -> {:reply, %{error: "insert_document_failed"}}
    end
  end

  @impl true
  def handle_event(
        "copy_layers",
        %{"layer_ids" => layer_ids},
        %{},
        %{:document_id => document_id},
        _socket
      )
      when is_list(layer_ids) do
    layer_ids =
      layer_ids
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    %{document_id: document_id, layer_ids: layer_ids, original_ids: true}
    |> RenewCollab.Queries.StrippedDocument.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> then(fn {:ok, stripped_document} ->
      clipboard = RenewCollab.Document.LayerClipboard.encode(stripped_document)

      case RenewCollab.Document.LayerClipboard.to_rnw(stripped_document) do
        {:ok, rnw} -> {:reply, %{clipboard: clipboard, rnw: rnw}}
        _ -> {:reply, %{clipboard: clipboard}}
      end
    end)
  end

  @impl true
  def handle_event(
        "import_rnw_clipboard",
        %{"content" => content},
        %{},
        %{},
        _socket
      )
      when is_binary(content) do
    case RenewCollab.Document.LayerClipboard.from_rnw("clipboard.rnw", content) do
      {:ok, clipboard} -> {:reply, %{clipboard: clipboard}}
      _ -> {:reply, %{error: "invalid_rnw_clipboard"}}
    end
  end

  @impl true
  def handle_event(
        "paste_layers",
        %{
          "clipboard" => clipboard,
          "position" => %{"x" => x, "y" => y}
        },
        %{},
        %{:document_id => document_id, :account => account},
        socket
      ) do
    %Actions.DocumentEditPasteLayers{
      document_id: document_id,
      clipboard: clipboard,
      position: {x, y}
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer_ids: layer_ids}} -> reply_with_selection(socket, layer_ids)
      :ok -> :ack
      {:error, reason} -> {:reply, %{error: inspect(reason)}}
      _ -> {:reply, %{error: "paste_failed"}}
    end
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "text", "attr" => style_attr, "val" => value} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerTextStyle{
        document_id: document_id,
        layer_ids: layer_ids,
        style_attr: style_attr,
        value: value
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "change_text_type",
        %{"renew_type" => renew_type} = params,
        %{},
        %{document_id: document_id, account: account},
        _socket
      )
      when is_integer(renew_type) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerTextType{
        document_id: document_id,
        layer_ids: layer_ids,
        renew_type: renew_type
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "edge", "attr" => style_attr, "val" => value} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerEdgeStyle{
        document_id: document_id,
        layer_ids: layer_ids,
        style_attr: style_attr,
        value: value
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "layer", "attr" => style_attr, "val" => value} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerStyle{
        document_id: document_id,
        layer_ids: layer_ids,
        style_attr: style_attr,
        value: value
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "link_layer",
        %{"layer_id" => layer_id, "target_layer_id" => target_layer_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(layer_id) and is_binary(target_layer_id) do
    %Actions.DocumentEditLinkLayer{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "unlink_layer",
        %{"layer_id" => layer_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(layer_id) do
    %Actions.DocumentEditUnlinkLayer{
      document_id: document_id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_edge_attributes",
        %{"attrs" => attributes} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_map(attributes) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerEdgeAttributes{
        document_id: document_id,
        layer_ids: layer_ids,
        attributes: attributes
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "change_edge_direction",
        %{"layer_id" => layer_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(layer_id) do
    %Actions.DocumentEditLayerEdgeSwapDirection{
      document_id: document_id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_text_body",
        %{"layer_id" => layer_id, "val" => new_body},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(new_body) and is_binary(layer_id) do
    %Actions.DocumentEditLayerTextBody{
      document_id: document_id,
      layer_id: layer_id,
      new_body: new_body
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_layer_shape",
        %{"shape_id" => shape_id} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(shape_id) do
    layer_ids = style_layer_ids(params)

    if layer_ids != [] do
      %Actions.DocumentEditLayerBoxShape{
        document_id: document_id,
        layer_ids: layer_ids,
        shape_id: shape_id,
        attributes: Map.get(params, "attributes", %{})
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "set_visibility",
        %{"layer_id" => layer_id, "visible" => visible},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditSetLayerVisibility{
      document_id: document_id,
      layer_id: layer_id,
      visible: visible
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "set_socket_schema",
        %{"layer_id" => layer_id, "val" => socket_schema_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerAssignSocketSchema{
      document_id: document_id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "set_semantic_tag",
        %{"layer_id" => layer_id, "val" => new_tag},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerSemanticTag{
      document_id: document_id,
      layer_id: layer_id,
      new_tag: new_tag
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "update_box_size",
        %{
          "layer_id" => layer_id,
          "value" => new_size
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerBoxSize{
      document_id: document_id,
      layer_id: layer_id,
      new_size: new_size
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "update_text_size_hint",
        %{
          "layer_id" => layer_id,
          "box" => box
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerTextSizeHint{
      document_id: document_id,
      layer_id: layer_id,
      box: box
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "delete_waypoint",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditDeleteEdgeWaypoint{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "update_waypoint_position",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id,
          "value" => %{
            "x" => position_x,
            "y" => position_y
          }
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerEdgeWaypointPosition{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: %{
        "position_x" => position_x,
        "position_y" => position_y
      }
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => prev_waypoint_id,
          "position" => %{
            "x" => position_x,
            "y" => position_y
          }
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditCreateEdgeWaypoint{
      document_id: document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: {position_x, position_y}
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "create_bond",
        %{
          "edge_id" => edge_id,
          "kind" => kind,
          "layer_id" => layer_id,
          "socket_id" => socket_id
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when kind in ["source", "target"] do
    %Actions.DocumentEditCreateEdgeBond{
      document_id: document_id,
      edge_id: edge_id,
      kind: String.to_existing_atom(kind),
      layer_id: layer_id,
      socket_id: socket_id
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{update_edge_points: updated_edges}} ->
        updated_edges
        |> Enum.find(&(&1.id == edge_id or &1.layer_id == edge_id))
        |> edge_position_reply()

      {:error, reason} ->
        {:reply, %{error: inspect(reason)}}

      _ ->
        :silent
    end
  end

  @impl true
  def handle_event(
        "delete_bond",
        %{"bond_id" => bond_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditDeleteBond{
      document_id: document_id,
      bond_id: bond_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "update_edge_position",
        %{
          "layer_id" => layer_id,
          "value" => new_position
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerEdgePosition{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok,
       %{
         result_edge: %{
           source_x: source_x,
           source_y: source_y,
           target_x: target_x,
           target_y: target_y
         }
       }} ->
        {:reply,
         %{
           source_x: source_x,
           source_y: source_y,
           target_x: target_x,
           target_y: target_y
         }}

      _ ->
        :silent
    end
  end

  @impl true
  def handle_event(
        "update_edge_points",
        %{
          "layer_id" => layer_id,
          "value" => new_position,
          "waypoints" => waypoints
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerEdgePoints{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position,
      waypoints: waypoints
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok,
       %{
         result_edge: %{
           source_x: source_x,
           source_y: source_y,
           target_x: target_x,
           target_y: target_y
         }
       }} ->
        {:reply,
         %{
           source_x: source_x,
           source_y: source_y,
           target_x: target_x,
           target_y: target_y
         }}

      _ ->
        :silent
    end
  end

  @impl true
  def handle_event(
        "update_text_position",
        %{
          "layer_id" => layer_id,
          "value" =>
            %{
              "position_x" => _position_x,
              "position_y" => _position_y
            } = new_position
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditLayerTextPosition{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "move_layer",
        %{
          "layer_ids" => layer_ids,
          "target_layer_id" => target_layer_id,
          "order" => order,
          "relative" => relative
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    if layer_ids != [] do
      %Actions.DocumentEditReorderLayer{
        document_id: document_id,
        layer_ids: layer_ids,
        target_layer_id: target_layer_id,
        target: Actions.DocumentEditReorderLayer.parse_hierarchy_position(order, relative)
      }
      |> Dispatcher.perform_as(account)
    end

    :silent
  end

  @impl true
  def handle_event(
        "move_layer_relative",
        %{
          "layer_ids" => layer_ids,
          "dx" => dx,
          "dy" => dy
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    if layer_ids != [] do
      %Actions.DocumentEditMoveLayerRelative{
        document_id: document_id,
        layer_ids: layer_ids,
        dx: dx,
        dy: dy
      }
      |> Dispatcher.perform_as(account)
    end

    :ack
  end

  @impl true
  def handle_event(
        "reorder_relative",
        %{"layer_ids" => layer_ids, "target_rel" => target_rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    {rel, target} = Actions.DocumentEditReorderLayerRelative.parse_direction(target_rel)
    layer_ids = normalize_selection(layer_ids)

    if layer_ids != [] do
      %Actions.DocumentEditReorderLayerRelative{
        document_id: document_id,
        layer_ids: layer_ids,
        relative_direction: rel,
        target: target
      }
      |> Dispatcher.perform_as(account)
    end

    {:reply, %{layer_ids: layer_ids}}
  end

  @impl true
  def handle_event(
        "fetch_linked",
        %{"layer_ids" => layer_ids, "rel" => "direct"},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerHyperlinked{
          document_id: document_id,
          layer_id: layer_id,
          deep: false
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "fetch_linked",
        %{"layer_ids" => layer_ids, "rel" => "deep"},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerHyperlinked{
          document_id: document_id,
          layer_id: layer_id,
          deep: true
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "fetch_relative_graph",
        %{"layer_ids" => layer_ids, "rel" => rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerGraphConnection{
          document_id: document_id,
          layer_id: layer_id,
          rel: Views.DocumentLayerGraphConnection.parse_relative(rel)
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "fetch_relative_many",
        %{"layer_ids" => layer_ids, "rel" => rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerRelativeMultiple{
          document_id: document_id,
          layer_id: layer_id,
          rel: Views.DocumentLayerRelativeMultiple.parse_relative(rel)
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "fetch_relative",
        %{"layer_ids" => layer_ids, "rel" => rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerRelative{
          document_id: document_id,
          layer_id: layer_id,
          id_only: true,
          relative: Views.DocumentLayerRelative.parse_relative(rel)
        }
        |> Fetcher.fetch_as(account)
      end)
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "fetch_reachable",
        %{"layer_ids" => layer_ids, "rel" => rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids = normalize_selection(layer_ids)

    %{uplink: uplink, downlink: downlink} = Views.DocumentLayerReachable.parse_direction(rel)

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerReachable{
          document_id: document_id,
          layer_id: layer_id,
          uplink: uplink,
          downlink: downlink
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    {:reply, %{layer_ids: rel_ids}}
  end

  @impl true
  def handle_event(
        "make_space",
        %{
          "base" => %{"x" => bx, "y" => by},
          "dir" => %{"x" => dx, "y" => dy}
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditMakeSpaceBetween{
      document_id: document_id,
      base: {bx, by},
      direction: {dx, dy},
      inverse: Map.get(params, "inverse", false)
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "set_meta",
        params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentUpdateMeta{
      document_id: document_id,
      meta: params
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event(
        "set_thumbnail",
        %{"layer_id" => layer_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditSetThumbnail{
      document_id: document_id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event(
        "insert_file",
        %{"content" => content, "file_name" => file_name, "x" => x, "y" => y},
        %{},
        %{:document_id => document_id, :account => account},
        socket
      ) do
    %Actions.DocumentEditImportFile{
      document_id: document_id,
      file_name: file_name,
      file_content: content,
      x: x,
      y: y
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer_ids: layer_ids}} -> reply_with_selection(socket, layer_ids)
      :ok -> :ack
      {:error, reason} -> {:reply, %{error: inspect(reason)}}
      _ -> {:reply, %{error: "insert_file_failed"}}
    end
  end

  @impl true
  def handle_event(event_name, _payload, _state, _scope, _socket) do
    {:reply, %{error: "unknown_document_event", event: event_name}}
  end

  defp default_box_size(%{"semantic_tag" => "de.renew.gui.PlaceFigure"}), do: {20, 20}
  defp default_box_size(%{"semantic_tag" => "de.renew.gui.TransitionFigure"}), do: {24, 16}
  defp default_box_size(%{"semantic_tag" => "de.renew.fa.figures.FAStateFigure"}), do: {40, 40}
  defp default_box_size(_params), do: {50, 50}

  defp polygon_layer_style(params, cyclic) do
    case Map.fetch(params, "layer_style") do
      {:ok, style} -> style
      :error when cyclic -> %{"background_color" => "#70DB93"}
      :error -> nil
    end
  end

  defp outgoing_link_attrs(params) do
    case Map.get(params, "hyperlink", nil) do
      nil -> nil
      target_id -> %{"target_layer_id" => target_id}
    end
  end

  defp edge_style_attrs(params) do
    params
    |> Map.get("style", %{})
    |> Kernel.||(%{})
    |> put_optional_edge_style(params, "source_tip_symbol_shape_id")
    |> put_optional_edge_style(params, "target_tip_symbol_shape_id")
    |> put_optional_edge_style(params, "smoothness_amount")
  end

  defp put_optional_edge_style(style, params, key) do
    if Map.has_key?(params, key) do
      Map.put(style, key, Map.get(params, key))
    else
      style
    end
  end

  defp edge_waypoint_attrs(params) do
    params
    |> Map.get("waypoints", [])
    |> List.wrap()
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {%{"x" => x, "y" => y}, sort} ->
        [%{position_x: x, position_y: y, sort: sort}]

      {%{"position_x" => x, "position_y" => y}, sort} ->
        [%{position_x: x, position_y: y, sort: sort}]

      _ ->
        []
    end)
  end

  defp edge_position_reply(nil), do: :silent

  defp edge_position_reply(edge) do
    {:reply,
     %{
       source_x: edge.source_x,
       source_y: edge.source_y,
       target_x: edge.target_x,
       target_y: edge.target_y
     }}
  end

  defp reply_with_selection(socket, selection) do
    selection = normalize_selection(selection)
    account_id = socket.assigns.current_account.id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: selection
      })
    )

    {:reply, %{layer_ids: selection}}
  end

  defp style_layer_ids(params) do
    params
    |> Map.get("layer_ids", Map.get(params, "layer_id"))
    |> normalize_selection()
  end

  defp normalize_selection(selection) when is_list(selection) do
    selection
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp normalize_selection(selection) when is_binary(selection), do: [selection]
  defp normalize_selection(_selection), do: []

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
