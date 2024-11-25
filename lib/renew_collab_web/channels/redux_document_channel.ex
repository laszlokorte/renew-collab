defmodule RenewCollabWeb.ReduxDocumentChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_document:" <> document_id, _params, socket) do
    case RenewCollab.Renew.get_document_with_elements(document_id) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
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
         assign(socket, :document_id, document_id)}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, _state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.show_content(
       RenewCollab.Renew.get_document_with_elements(document_id)
     )}
  end

  @impl true
  def handle_event("cursor", %{"x" => x, "y" => y}, _state, socket) do
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
  def handle_event("cursor", %{}, _state, socket) do
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
  def handle_event("select", %{}, _state, socket) do
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
  def handle_event("select", layer_id, _state, socket) when is_binary(layer_id) do
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
  def handle_event("restore_snapshot", snapshot_id, _state, socket) when is_binary(snapshot_id) do
    RenewCollab.Commands.RestoreSnapshot.new(%{
      document_id: socket.assigns.document_id,
      snapshot_id: snapshot_id
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event("delete_layer", layer_id, _state, socket) when is_binary(layer_id) do
    RenewCollab.Commands.DeleteLayer.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      delete_children: true
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "create_layer",
        params = %{"pos" => %{"x" => cx, "y" => cy}, "shape_id" => shape_id},
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: socket.assigns.document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", nil),
        "box" => %{
          "position_x" => cx - 25,
          "position_y" => cy - 25,
          "width" => 50,
          "height" => 50,
          "symbol_shape_id" => shape_id
        },
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
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}, socket}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        params = %{
          "pos" => %{"x" => x, "y" => y, "width" => width, "height" => height},
          "image" => background_url
        },
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: socket.assigns.document_id,
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
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}, socket}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        params = %{"points" => points},
        %{},
        socket
      )
      when is_list(points) and length(points) > 1 do
    %{"x" => source_x, "y" => source_y} = Enum.at(points, 0)
    %{"x" => target_x, "y" => target_y} = Enum.at(points, -1)

    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: socket.assigns.document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.PolyLineFigure"),
        "edge" => %{
          "source_x" => source_x,
          "source_y" => source_y,
          "target_x" => target_x,
          "target_y" => target_y,
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
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}, socket}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        params = %{"pos" => %{"x" => position_x, "y" => position_y}, "body" => body},
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: socket.assigns.document_id,
      attrs: %{
        "semantic_tag" => Map.get(params, "semantic_tag", "CH.ifa.draw.figures.TextFigure"),
        "text" => %{
          "position_x" => position_x,
          "position_y" => position_y,
          "body" => body,
          "style" => %{
            "font_size" => 40
          }
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
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}, socket}
    end
  end

  @impl true
  def handle_event(
        "create_layer",
        params = %{
          "source" => %{"socket_id" => source_socket_id, "layer_id" => source_layer_id},
          "target" => %{"socket_id" => target_socket_id, "layer_id" => target_layer_id}
        },
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: Map.get(params, "base_layer_id", nil),
      document_id: socket.assigns.document_id,
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
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{layer: layer}} ->
        {:reply, %{id: layer.id}, socket}
    end
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "text", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    RenewCollab.Commands.UpdateLayerTextStyle.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "edge", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    RenewCollab.Commands.UpdateLayerEdgeStyle.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "change_style",
        %{"type" => "layer", "attr" => style_attr, "layer_id" => layer_id, "val" => value},
        %{},
        socket
      )
      when is_binary(style_attr) and is_binary(layer_id) do
    RenewCollab.Commands.UpdateLayerStyle.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "change_text_body",
        %{"layer_id" => layer_id, "val" => new_body},
        %{},
        socket
      )
      when is_binary(new_body) and is_binary(layer_id) do
    RenewCollab.Commands.UpdateLayerTextBody.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      new_body: new_body
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "change_layer_shape",
        %{"layer_id" => layer_id, "shape_id" => shape_id},
        %{},
        socket
      )
      when is_binary(shape_id) and is_binary(layer_id) do
    RenewCollab.Commands.UpdateLayerBoxShape.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: %{}
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event("set_visibility", %{"layer_id" => layer_id, "visible" => visible}, %{}, socket) do
    RenewCollab.Commands.SetVisibility.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      visible: visible
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "set_socket_schema",
        %{"layer_id" => layer_id, "val" => socket_schema_id},
        %{},
        socket
      ) do
    RenewCollab.Commands.AssignLayerSocketSchema.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event("set_semantic_tag", %{"layer_id" => layer_id, "val" => new_tag}, %{}, socket) do
    RenewCollab.Commands.UpdateLayerSemanticTag.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      new_tag: new_tag
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.UpdateLayerBoxSize.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      new_size: new_size
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.DeleteLayerEdgeWaypoint.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.UpdateLayerEdgeWaypointPosition.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: %{
        "position_x" => position_x,
        "position_y" => position_y
      }
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.CreateLayerEdgeWaypoint.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: {position_x, position_y}
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.UpdateLayerEdgePosition.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
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
        socket
      ) do
    RenewCollab.Commands.UpdateLayerTextPosition.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.Commander.run_document_command()

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
        socket
      ) do
    RenewCollab.Commands.ReorderLayer.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: RenewCollab.Commands.ReorderLayer.parse_hierarchy_position(order, relative)
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "reorder_relative",
        %{"id" => layer_id, "target_rel" => target_rel},
        %{},
        socket
      ) do
    {rel, target} = RenewCollab.Commands.ReorderLayerRelative.parse_direction(target_rel)

    RenewCollab.Commands.ReorderLayerRelative.new(%{
      document_id: socket.assigns.document_id,
      layer_id: layer_id,
      relative_direction: rel,
      target: target
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "fetch_relative",
        %{"id" => layer_id, "rel" => rel},
        %{},
        socket
      ) do
    rel_id =
      RenewCollab.Queries.LayerHierarchyRelative.new(%{
        document_id: socket.assigns.document_id,
        layer_id: layer_id,
        id_only: true,
        relative: RenewCollab.Queries.LayerHierarchyRelative.parse_relative(rel)
      })
      |> RenewCollab.Fetcher.fetch()

    {:reply, %{id: rel_id}, socket}
  end

  @impl true
  def handle_event(
        "make_space",
        %{
          "base" => %{"x" => bx, "y" => by},
          "dir" => %{"x" => dx, "y" => dy}
        } = params,
        %{},
        socket
      ) do
    RenewCollab.Commands.MakeSpaceBetween.new(%{
      document_id: socket.assigns.document_id,
      base: {bx, by},
      direction: {dx, dy},
      inverse: Map.get(params, "inverse", false)
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event("set_meta", params, %{}, socket) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: socket.assigns.document_id,
      meta: params
    })
    |> RenewCollab.Commander.run_document_command()

    :ack
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
