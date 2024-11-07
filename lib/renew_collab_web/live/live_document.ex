defmodule RenewCollabWeb.LiveDocument do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Versioning
  alias RenewCollab.Renew
  alias RenewCollab.Symbols
  alias RenewCollab.Sockets

  @renew_grammar Renewex.Grammar.new(11)

  def renew_grammar do
    @renew_grammar
  end

  def mount(%{"id" => id}, _session, socket) do
    with document when not is_nil(document) <- Renew.get_document_with_elements(id) do
      socket =
        socket
        |> assign(:document, document)
        |> assign_async(
          [
            :symbols,
            :socket_schemas,
            :undo_redo,
            :other_documents,
            :snapshots,
            :hierachy_missing,
            :hierachy_invalid
          ],
          fn ->
            {:ok,
             %{
               undo_redo: Versioning.document_undo_redo(id),
               other_documents: Renew.list_documents(),
               snapshots: Versioning.document_versions(id),
               socket_schemas: Sockets.all_socket_schemas(),
               symbols: Symbols.list_shapes() |> Enum.map(fn s -> {s.id, s} end) |> Map.new(),
               hierachy_missing: RenewCollab.Hierarchy.find_missing(id),
               hierachy_invalid: RenewCollab.Hierarchy.find_invalids(id)
             }}
          end
        )
        |> assign(:selection, nil)
        |> assign(:show_hierarchy, false)
        |> assign(:show_selected, false)
        |> assign(:show_snapshots, false)
        |> assign(:show_health, false)
        |> assign(:show_meta, false)
        |> assign(:viewbox, viewbox(document))

      RenewCollabWeb.Endpoint.subscribe("document:#{id}")
      {:ok, socket}
    else
      _ -> {:ok, redirect(socket, to: "/documents")}
    end
  end

  def render(assigns) do
    ~H"""
    <div style="position: absolute; top:0;left:0;bottom: 0; right:0;display: grid; width: 100vw; height: 100vh; grid-template-rows: [top-start right-start] auto [top-end left-start ] 1fr [left-end right-end]; grid-template-columns: [left-start top-start]1fr [top-end left-end right-start]auto [right-end];">
      <div style="grid-area: top; padding: 1em; background: #333; color: #fff; display: flex; justify-content: space-between; align-items: stretch;">
        <div>
          <.link navigate={~p"/documents"} style="color: inherit">Back</.link>
          <h2 style="margin: 0;"><%= @document.name %></h2>
        </div>

        <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: undo_redo} <- @undo_redo do %>
          <.live_component
            id="undo_redo"
            module={RenewCollabWeb.UndoRedoComponent}
            undo_redo={undo_redo}
          />
          <% else _ -> %>
        <% end %>
      </div>

      <div style="grid-area: left; width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0">
        <datalist id="all-semantic-tags">
          <%= for {class_name, _} <- renew_grammar().hierarchy do %>
            <option><%= class_name %></option>
          <% end %>
        </datalist>

        <svg
          phx-click="select_layer"
          phx-value-id=""
          preserveAspectRatio="xMidYMin meet"
          id={"document-#{@document.id}"}
          viewBox={RenewCollab.ViewBox.into_string(@viewbox)}
          style="display: block; width: 100%; height: 100%;background: #f5f5f5;"
          width={@viewbox.width}
          height={@viewbox.height}
        >
          <rect
            x={@viewbox.x}
            y={@viewbox.y}
            width={@viewbox.width}
            height={@viewbox.height}
            fill="#fff"
            stroke="#aaa"
            stroke-width="2"
          />
          <%= for layer <- @document.layers, layer.direct_parent == nil do %>
            <.live_component
              selectable={true}
              id={layer.id}
              module={RenewCollabWeb.HierarchyLayerComponent}
              socket_schemas={@socket_schemas}
              document={@document}
              layer={layer}
              selection={@selection}
              selected={@selection == layer.id}
              symbols={@symbols}
            />
          <% end %>
        </svg>
      </div>

      <div style="grid-area: right;width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0 2em; background: #eee">
        <p>
          <button
            phx-click="update-viewbox"
            style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
          >
            Refit Camera
          </button>
        </p>

        <div style="display: flex; gap: 1ex; padding: 1ex 0">
          <button
            type="button"
            phx-click="create_group"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Group
          </button>

          <button
            type="button"
            phx-click="create_text"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Text
          </button>

          <button
            type="button"
            phx-click="create_box"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Box
          </button>

          <button
            type="button"
            phx-click="create_edge"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Line
          </button>

          <form target="" phx-change="insert_document">
            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: other_documents} <- @other_documents do %>
              <select name="document_id" onchange="this.value=''">
                <option value="" selected>Insert Other Document</option>

                <%= for doc <- other_documents, doc.id != @document.id do %>
                  <option value={doc.id}><%= doc.name %></option>
                <% end %>
              </select>
              <% else _ -> %>
                Loading...
            <% end %>
          </form>
        </div>

        <h2 style="cursor: pointer;" phx-click="toggle-meta">
          <span><%= if(@show_meta, do: "▼", else: "►") %></span> Document
        </h2>

        <%= if @show_meta do %>
          <div style="width: 45vw;">
            <form id={"document-rename-#{@document.id}"} phx-hook="RnwDocumentRename">
              <dl style="display: grid; grid-template-columns: auto 1fr;gap:1ex; align-items: baseline">
                <dt style="margin: 0; text-align: right;">Document Id</dt>

                <dd style="margin: 0;">
                  <input
                    readonly
                    disabled
                    type="text"
                    value={@document.id}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                  />
                  <.link
                    target="_blank"
                    style="color: #078"
                    navigate={~p"/documents/#{@document.id}/inspect"}
                  >
                    Inspect
                  </.link>
                </dd>

                <dt style="margin: 0; text-align: right;">Document Name</dt>

                <dd style="margin: 0;">
                  <input
                    type="text"
                    name="name"
                    value={@document.name}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                  />
                </dd>

                <dt style="margin: 0; text-align: right;">Kind</dt>

                <dd style="margin: 0;">
                  <input
                    type="text"
                    name="kind"
                    value={@document.kind}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                    list="all-semantic-tags"
                  />
                </dd>

                <dt style="margin: 0; text-align: right;"></dt>

                <dd style="margin: 0;">
                  <button
                    style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
                    type="submit"
                  >
                    Save
                  </button>
                </dd>
              </dl>
            </form>
          </div>
        <% end %>

        <h2
          {if(@selection, do: [style: "cursor: pointer;"], else: [style: "cursor: pointer; color: #aaa"])}
          phx-click="toggle-selected"
        >
          <span><%= if(@show_selected, do: "▼", else: "►") %></span> Selected
        </h2>

        <%= if @show_selected do %>
          <div style="width: 45vw;">
            <%= with selected_layer when selected_layer != nil <- Enum.find(@document.layers, &(&1.id == @selection)) do %>
              <.live_component
                id="layer-properties"
                module={RenewCollabWeb.LayerPropertiesComponent}
                socket_schemas={@socket_schemas}
                document={@document}
                symbols={@symbols}
                layer={selected_layer}
              />
            <% end %>
          </div>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-hierarchy">
          <span><%= if(@show_hierarchy, do: "▼", else: "►") %></span> Hierarchy
        </h2>

        <%= if @show_hierarchy do %>
          <div style="width: 45vw;">
            <.live_component
              id="hierarchy-list"
              module={RenewCollabWeb.HierarchyListComponent}
              socket_schemas={@socket_schemas}
              document={@document}
              symbols={@symbols}
              selection={@selection}
            />
          </div>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-snapshots">
          <span><%= if(@show_snapshots, do: "▼", else: "►") %></span> Snapshots
        </h2>

        <%= if @show_snapshots do %>
          <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: snapshots} <- @snapshots do %>
            <.live_component
              id="snapshot-list"
              module={RenewCollabWeb.SnapshotListComponent}
              snapshots={snapshots}
            />
            <% else _ -> %>
              <p>Loading</p>
          <% end %>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-health">
          <span><%= if(@show_health, do: "▼", else: "►") %></span> Health
        </h2>

        <%= if @show_health do %>
          <div style="width: 45vw;">
            <dl style="display: grid; grid-template-columns: auto auto; justify-content: start; gap: 1ex 1em">
              <dt style="margin: 0">Missing Parenthoods</dt>

              <dd style="margin: 0">
                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: hierachy_missing} <- @hierachy_missing do %>
                  <details>
                    <summary style="cursor: pointer"><%= Enum.count(hierachy_missing) %></summary>

                    <ul>
                      <%= for i <- hierachy_missing do %>
                        <li><%= i.ancestor_id %>/<%= i.descendant_id %>/<%= i.depth %></li>
                      <% end %>
                    </ul>
                  </details>
                  <% else _ -> %>
                    Loading
                <% end %>
              </dd>

              <dt style="margin: 0">Invalid Parenthoods</dt>

              <dd style="margin: 0">
                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: hierachy_invalid} <- @hierachy_invalid do %>
                  <details>
                    <summary style="cursor: pointer"><%= Enum.count(hierachy_invalid) %></summary>

                    <ul>
                      <%= for id <- hierachy_invalid do %>
                        <li><%= id %></li>
                      <% end %>
                    </ul>
                  </details>
                  <% else _ -> %>
                    Loading
                <% end %>
              </dd>

              <dt></dt>

              <dd style="margin: 0">
                <button
                  type="button"
                  phx-click="repair_hierarchy"
                  style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
                >
                  Repair
                </button>
              </dd>
            </dl>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp viewbox(document) do
    RenewCollab.ViewBox.calculate(document)
  end

  def viewbox_center(viewbox) do
    RenewCollab.ViewBox.center(viewbox)
  end

  def handle_event("toggle_visible", %{"id" => layer_id}, socket) do
    RenewCollab.Commands.ToggleVisible.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event("toggle-hierarchy", %{}, socket) do
    {:noreply, socket |> update(:show_hierarchy, &(not &1))}
  end

  def handle_event("toggle-selected", %{}, socket) do
    {:noreply, socket |> update(:show_selected, &(not &1))}
  end

  def handle_event("toggle-snapshots", %{}, socket) do
    {:noreply, socket |> update(:show_snapshots, &(not &1))}
  end

  def handle_event("toggle-meta", %{}, socket) do
    {:noreply, socket |> update(:show_meta, &(not &1))}
  end

  def handle_event("toggle-health", %{}, socket) do
    {:noreply, socket |> update(:show_health, &(not &1))}
  end

  def handle_event("update-viewbox", %{}, socket) do
    {:noreply,
     socket
     |> assign(:viewbox, viewbox(socket.assigns.document))}
  end

  def handle_event("detach-bond", %{"id" => bond_id}, socket) do
    RenewCollab.Commands.DeleteBond.new(%{
      document_id: socket.assigns.document.id,
      bond_id: bond_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event("repair_hierarchy", %{}, socket) do
    document_id = socket.assigns.document.id
    RenewCollab.Hierarchy.repair_parenthood(document_id)

    {:noreply,
     socket
     |> assign_async(
       [
         :hierachy_missing,
         :hierachy_invalid
       ],
       fn ->
         {:ok,
          %{
            hierachy_missing: RenewCollab.Hierarchy.find_missing(document_id),
            hierachy_invalid: RenewCollab.Hierarchy.find_invalids(document_id)
          }}
       end
     )}
  end

  def handle_event("select_layer", %{"id" => ""}, socket) do
    {:noreply,
     socket
     |> assign(:selection, nil)}
  end

  def handle_event("select_layer", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:selection, id)}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "layer",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerStyle.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "edge",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerEdgeStyle.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "text",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerTextStyle.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_text_size_hint",
        %{
          "layer_id" => layer_id,
          "box" => box
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerTextSizeHint.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      box: box
    })
    |> RenewCollab.Commander.run_document_command(false)

    {:noreply, socket}
  end

  def handle_event("update_text_body", %{"layer_id" => layer_id, "value" => new_body}, socket) do
    RenewCollab.Commands.UpdateLayerTextBody.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_body: new_body
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_box_size",
        %{
          "layer_id" => layer_id,
          "value" => new_size
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerBoxSize.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_size: new_size
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

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
        socket
      ) do
    RenewCollab.Commands.UpdateLayerTextPosition.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_edge_position",
        %{
          "layer_id" => layer_id,
          "value" => new_position
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerEdgePosition.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_position: new_position
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_z_index",
        %{
          "layer_id" => layer_id,
          "value" => new_z_index
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerZIndex.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      z_index: new_z_index
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_waypoint_position",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id,
          "value" =>
            %{
              "position_x" => _position_x,
              "position_y" => _position_y
            } = new_position
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerEdgeWaypointPosition.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: new_position
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "delete_waypoint",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id
        },
        socket
      ) do
    RenewCollab.Commands.DeleteLayerEdgeWaypoint.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => prev_waypoint_id,
          "position_x" => position_x,
          "position_y" => position_y
        },
        socket
      ) do
    RenewCollab.Commands.CreateLayerEdgeWaypoint.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: {position_x, position_y}
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => prev_waypoint_id
        },
        socket
      ) do
    RenewCollab.Commands.CreateLayerEdgeWaypoint.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "clear_waypoints",
        %{
          "layer_id" => layer_id
        },
        socket
      ) do
    RenewCollab.Commands.RemoveAllLayerEdgeWaypoints.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_semantic_tag",
        %{
          "layer_id" => layer_id,
          "value" => new_tag
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerSemanticTag.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_tag: new_tag
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_shape",
        %{
          "layer_id" => layer_id,
          "value" => %{"shape_id" => shape_id, "shape_attributes" => shape_attributes}
        },
        socket
      ) do
    RenewCollab.Commands.UpdateLayerBoxShape.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: shape_attributes
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "move_layer",
        %{
          "layer_id" => layer_id,
          "target_layer_id" => target_layer_id,
          "order" => order,
          "relative" => relative
        },
        socket
      ) do
    RenewCollab.Commands.MoveLayer.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: RenewCollab.Commands.MoveLayer.parse_hierarchy_position(order, relative)
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "move_layer_relative",
        %{
          "layer_id" => layer_id,
          "dx" => dx,
          "dy" => dy
        },
        socket
      ) do
    RenewCollab.Commands.MoveLayerRelative.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      dx: dx,
      dy: dy
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "delete_layer",
        %{"id" => layer_id},
        socket
      ) do
    RenewCollab.Commands.DeleteLayer.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      delete_children: true
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_group",
        %{"example" => "yes"},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.GroupFigure"
      }
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_text",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.TextFigure",
        "text" => %{
          "position_x" => cx,
          "position_y" => cy,
          "body" => "Hello World"
        }
      }
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_box",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.RectangleFigure",
        "box" => %{
          "position_x" => cx - 100,
          "position_y" => cy - 50,
          "width" => 200,
          "height" => 100
        }
      }
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_edge",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.PolyLineFigure",
        "edge" => %{
          "source_x" => cx - 100,
          "source_y" => cy - 50,
          "target_x" => cx + 100,
          "target_y" => cy + 50
        }
      }
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_edge",
        %{} = edge,
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.PolyLineFigure",
        "edge" => edge
      }
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_edge_bond",
        %{
          "edge_id" => edge_id,
          "kind" => kind,
          "layer_id" => layer_id,
          "socket_id" => socket_id
        },
        socket
      ) do
    RenewCollab.Commands.CreateEdgeBond.new(%{
      document_id: socket.assigns.document.id,
      edge_id: edge_id,
      kind: kind,
      layer_id: layer_id,
      socket_id: socket_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "unlink_layer",
        %{
          "id" => layer_id
        },
        socket
      ) do
    RenewCollab.Commands.UnlinkLayer.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "link_layer",
        %{
          "source_layer_id" => layer_id,
          "target_layer_id" => target_layer_id
        },
        socket
      ) do
    RenewCollab.Commands.LinkLayer.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "assign_layer_socket_schema",
        %{
          "layer_id" => layer_id,
          "socket_schema_id" => socket_schema_id
        },
        socket
      ) do
    RenewCollab.Commands.AssignLayerSocketSchema.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "remove_layer_socket_schema",
        %{
          "layer_id" => layer_id
        },
        socket
      ) do
    RenewCollab.Commands.RemoveLayerSocketSchema.new(%{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_snapshot",
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateSnapshot.new(%{document_id: socket.assigns.document.id})
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "restore",
        %{"id" => snapshot_id},
        socket
      ) do
    RenewCollab.Commands.RestoreSnapshot.new(%{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "create_snapshot_label",
        %{"snapshot_id" => snapshot_id, "description" => description},
        socket
      ) do
    RenewCollab.Commands.CreateSnapshotLabel.new(%{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id,
      description: description
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "remove_snapshot_label",
        %{"id" => snapshot_id},
        socket
      ) do
    RenewCollab.Commands.RemoveSnapshotLabel.new(%{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "prune_snaphots",
        %{},
        socket
      ) do
    RenewCollab.Commands.PruneSnapshots.new(%{document_id: socket.assigns.document.id})
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "update_document_meta",
        meta,
        socket
      ) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: socket.assigns.document.id,
      meta: meta
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  def handle_event(
        "insert_document",
        %{"document_id" => document_id},
        socket
      ) do
    case document_id do
      "" ->
        nil

      id ->
        RenewCollab.Commands.InsertDocument.new(%{
          target_document_id: socket.assigns.document.id,
          source_document_id: id
        })
        |> RenewCollab.Commander.run_document_command()
    end

    {:noreply, socket}
  end

  def handle_info({:document_changed, document_id}, socket) do
    if document_id == socket.assigns.document.id do
      {:noreply,
       socket
       |> assign_async(
         [:undo_redo],
         fn ->
           {:ok,
            %{
              undo_redo: Versioning.document_undo_redo(document_id)
            }}
         end
       )
       |> assign_async(
         [:snapshots],
         fn ->
           {:ok,
            %{
              snapshots: Versioning.document_versions(document_id)
            }}
         end
       )
       |> assign(:document, Renew.get_document_with_elements(document_id))}
    end
  end

  def handle_info({:versions_changed, document_id}, socket) do
    if document_id == socket.assigns.document.id do
      {:noreply,
       socket
       |> assign_async(
         [:undo_redo],
         fn ->
           {:ok,
            %{
              undo_redo: Versioning.document_undo_redo(document_id)
            }}
         end
       )
       |> assign_async(
         [:snapshots],
         fn ->
           {:ok,
            %{
              snapshots: Versioning.document_versions(document_id)
            }}
         end
       )}
    end
  end
end
