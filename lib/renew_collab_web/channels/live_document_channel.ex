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
        params,
        _state,
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      case params do
        layer_id when is_binary(layer_id) ->
          [layer_id]

        %{} ->
          params
          |> Map.get("layer_ids", [Map.get(params, "layer_id")])
          |> normalize_selection()

        _ ->
          []
      end

    if layer_ids != [] do
      %Actions.DocumentEditDeleteLayer{
        document_id: document_id,
        layer_ids: layer_ids,
        delete_children: true
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
    width = Map.get(params, "width", 50)
    height = Map.get(params, "height", 50)

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
          "symbol_shape_id" => shape_id
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
        %{"pos" => %{"x" => cx, "y" => cy}, "shape_id" => shape_id} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    width = Map.get(params, "width", 50)
    height = Map.get(params, "height", 50)

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
          "symbol_shape_id" => shape_id
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

    %Actions.DocumentEditCreateLayer{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.PolyLineFigure"),
        "edge" => %{
          "source_x" => source_x,
          "source_y" => source_y,
          "target_x" => target_x,
          "target_y" => target_y,
          "cyclic" => Map.get(params, "cyclic", false),
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
          "style" => %{
            "target_tip_symbol_shape_id" => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          }
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
        _socket
      ) do
    %Actions.DocumentEditInsertDocument{
      target_document_id: target_document_id,
      source_document_id: source_document_id,
      position: {x, y}
    }
    |> Dispatcher.perform_as(account)

    :ack
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
    |> case do
      {:ok, stripped_document} ->
        {:reply, %{clipboard: RenewCollab.Document.LayerClipboard.encode(stripped_document)}}

      _ ->
        {:reply, %{error: "copy_failed"}}
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
        _socket
      ) do
    %Actions.DocumentEditPasteLayers{
      document_id: document_id,
      clipboard: clipboard,
      position: {x, y}
    }
    |> Dispatcher.perform_as(account)
    |> case do
      {:ok, %{layer_ids: layer_ids}} -> {:reply, %{layer_ids: layer_ids}}
      :ok -> :ack
      {:error, reason} -> {:reply, %{error: inspect(reason)}}
      _ -> {:reply, %{error: "paste_failed"}}
    end
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "text", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    %Actions.DocumentEditLayerTextStyle{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "edge", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    %Actions.DocumentEditLayerEdgeStyle{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "layer", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    %Actions.DocumentEditLayerStyle{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "change_edge_attributes",
        %{"layer_id" => layer_id, "attrs" => attributes},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_map(attributes) and is_binary(layer_id) do
    %Actions.DocumentEditLayerEdgeAttributes{
      document_id: document_id,
      layer_id: layer_id,
      attributes: attributes
    }
    |> Dispatcher.perform_as(account)

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
        %{"layer_id" => layer_id, "shape_id" => shape_id},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(shape_id) and is_binary(layer_id) do
    %Actions.DocumentEditLayerBoxShape{
      document_id: document_id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: %{}
    }
    |> Dispatcher.perform_as(account)

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
          "target_layer_id" => target_layer_id,
          "order" => order,
          "relative" => relative
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("layer_ids", [Map.get(params, "layer_id")])
      |> normalize_selection()

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
          "dx" => dx,
          "dy" => dy
        } = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("layer_ids", [Map.get(params, "layer_id")])
      |> List.wrap()
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

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
        %{"target_rel" => target_rel} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    {rel, target} = Actions.DocumentEditReorderLayerRelative.parse_direction(target_rel)

    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

    if layer_ids != [] do
      %Actions.DocumentEditReorderLayerRelative{
        document_id: document_id,
        layer_ids: layer_ids,
        relative_direction: rel,
        target: target
      }
      |> Dispatcher.perform_as(account)
    end

    {:reply, %{ids: layer_ids}}
  end

  @impl true
  def handle_event(
        "fetch_linked",
        %{"rel" => "direct"} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

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

    case params do
      %{"ids" => _} -> {:reply, %{ids: rel_ids}}
      %{"layer_ids" => _} -> {:reply, %{ids: rel_ids}}
      _ -> {:reply, %{id: List.first(rel_ids)}}
    end
  end

  @impl true
  def handle_event(
        "fetch_linked",
        %{"rel" => "deep"} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

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

    case params do
      %{"ids" => _} -> {:reply, %{ids: rel_ids}}
      %{"layer_ids" => _} -> {:reply, %{ids: rel_ids}}
      _ -> {:reply, %{id: List.first(rel_ids)}}
    end
  end

  @impl true
  def handle_event(
        "fetch_connected",
        %{"rel" => rel} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

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

    case params do
      %{"ids" => _} -> {:reply, %{ids: rel_ids}}
      %{"layer_ids" => _} -> {:reply, %{ids: rel_ids}}
      _ -> {:reply, %{id: List.first(rel_ids)}}
    end
  end

  @impl true
  def handle_event(
        "fetch_relative_many",
        %{"rel" => rel} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

    rel_ids =
      layer_ids
      |> Enum.map(fn layer_id ->
        %Views.DocumentLayerRelativeMultiple{
          document_id: document_id,
          layer_id: layer_id,
          relative: Views.DocumentLayerRelativeMultiple.parse_relative(rel)
        }
        |> Fetcher.fetch_as(account)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(&is_binary/1)

    case params do
      %{"ids" => _} -> {:reply, %{ids: rel_ids}}
      %{"layer_ids" => _} -> {:reply, %{ids: rel_ids}}
      _ -> {:reply, %{id: List.first(rel_ids)}}
    end
  end

  @impl true
  def handle_event(
        "fetch_relative",
        %{"rel" => rel} = params,
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    layer_ids =
      params
      |> Map.get("ids", Map.get(params, "layer_ids", [Map.get(params, "id")]))
      |> normalize_selection()

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

    case params do
      %{"ids" => _} -> {:reply, %{ids: rel_ids}}
      %{"layer_ids" => _} -> {:reply, %{ids: rel_ids}}
      _ -> {:reply, %{id: List.first(rel_ids)}}
    end
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
        _socket
      ) do
    %Actions.DocumentEditImportFile{
      document_id: document_id,
      file_name: file_name,
      file_content: content,
      x: x,
      y: y
    }
    |> Dispatcher.perform_as(account)

    :ack
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
