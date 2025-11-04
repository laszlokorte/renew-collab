defmodule RenewCollabWeb.ReduxDocumentChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views

  @impl true
  def init("redux_document:" <> document_id, _params, socket) do
    case %Views.DocumentWithContent{
           document_id: document_id
         }
         |> Fetcher.fetch_as(socket.assigns.current_account) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
        # TODO:subscription
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "document:#{document_id}")

        account_id = socket.assigns.current_account.account_id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: nil
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok, RenewCollabWeb.DocumentJSON.show_content(doc),
         %{:document_id => document_id, :account => socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, _state, %{
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
    account_id = socket.assigns.current_account.account_id

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
    account_id = socket.assigns.current_account.account_id

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
  def handle_event("select", %{}, _state, _scope, socket) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: nil
      })
    )

    :silent
  end

  @impl true
  def handle_event("select", layer_id, _state, _scope, socket) when is_binary(layer_id) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: layer_id
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
        layer_id,
        _state,
        %{:document_id => document_id, :account => account},
        _socket
      )
      when is_binary(layer_id) do
    %Actions.DocumentEditDeleteLayer{
      document_id: document_id,
      layer_id: layer_id,
      delete_children: true
    }
    |> Dispatcher.perform_as(account)

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
          "document_id" => document_id,
          "position" => %{"x" => x, "y" => y}
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditInsertDocument{
      target_document_id: document_id,
      source_document_id: document_id,
      position: {x, y}
    }
    |> Dispatcher.perform_as(account)

    :ack
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
          "layer_id" => layer_id,
          "target_layer_id" => target_layer_id,
          "order" => order,
          "relative" => relative
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditReorderLayer{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: Actions.DocumentEditReorderLayer.parse_hierarchy_position(order, relative)
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "move_layer_relative",
        %{
          "layer_id" => layer_id,
          "dx" => dx,
          "dy" => dy
        },
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    %Actions.DocumentEditMoveLayerRelative{
      document_id: document_id,
      layer_id: layer_id,
      dx: dx,
      dy: dy
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event(
        "reorder_relative",
        %{"id" => layer_id, "target_rel" => target_rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    {rel, target} = Actions.DocumentEditReorderLayerRelative.parse_direction(target_rel)

    %Actions.DocumentEditReorderLayerRelative{
      document_id: document_id,
      layer_id: layer_id,
      relative_direction: rel,
      target: target
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "fetch_relative",
        %{"id" => layer_id, "rel" => rel},
        %{},
        %{:document_id => document_id, :account => account},
        _socket
      ) do
    rel_id =
      %Views.DocumentLayerRelative{
        document_id: document_id,
        layer_id: layer_id,
        id_only: true,
        relative: Views.DocumentLayerRelative.parse_relative(rel)
      }
      |> Fetcher.fetch_as(account)

    {:reply, %{id: rel_id}}
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

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
