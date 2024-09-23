defmodule RenewCollabWeb.LiveDocument do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Versioning
  alias RenewCollab.Renew
  alias RenewCollab.Symbol

  def mount(%{"id" => id}, _session, socket) do
    document = Renew.get_document_with_elements!(id)

    socket =
      socket
      |> assign(:document, document)
      |> assign(:snapshots, Versioning.document_versions(id))
      |> assign(:undo_redo, Versioning.document_undo_redo(id))
      |> assign(:hierachy_missing, RenewCollab.RenewHierarchy.find_missing(id))
      |> assign(:hierachy_invalid, RenewCollab.RenewHierarchy.find_invalids(id))
      |> assign(:selection, nil)
      |> assign(:show_hierarchy, false)
      |> assign(:show_snapshots, false)
      |> assign(:symbols, Symbol.list_shapes() |> Enum.map(fn s -> {s.id, s} end) |> Map.new())
      |> assign(:viewbox, viewbox(document))

    RenewCollabWeb.Endpoint.subscribe("redux_document:#{id}")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="position: absolute; top:0;left:0;bottom: 0; right:0;display: grid; width: 100vw; height: 100vh; grid-template-rows: [top-start right-start] auto [top-end left-start ] 1fr [left-end right-end]; grid-template-columns: [left-start top-start]1fr [left-end right-start]auto [right-end top-end];">
      <div style="grid-area: top; padding: 1em; background: #333; color: #fff">
        <.link href={~p"/live/documents"} style="color: inherit">Back</.link>
      <h2 style="margin: 0;"><%= @document.name %></h2>
      </div>
      <div style="grid-area: left; width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0 2em">
      <svg   phx-click="select_layer" phx-value-id={""} preserveAspectRatio="xMidYMin meet" id={"document-#{@document.id}"} viewBox={@viewbox} style="display: block; width: 100%" width="1000" height="1000">
        <%= for layer <- @document.layers, layer.direct_parent == nil do %> 
          <.live_component selectable={true} id={layer.id} module={RenewCollabWeb.HierarchyLayerComponent} document={@document} layer={layer} selection={@selection} selected={@selection == layer.id} symbols={@symbols} />
        <% end %>
      </svg>
    </div>

      <div style="grid-area: right;width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0 2em; background: #eee">
        <p>
          <button phx-click="update-viewbox"  style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff">Refit Camera</button>
        </p>
        <h2 style="cursor: pointer; text-decoration: underline" phx-click="toggle-hierarchy">Hierarchy</h2>
          <div hidden={not @show_hierarchy}>
            <div style="width: 45vw;">
          <h3>Health</h3>
          <dl style="display: grid; grid-template-columns: auto auto; justify-content: start; gap: 1ex 1em">
            <dt style="margin: 0">Missing Parenthoods</dt>
            <dd style="margin: 0"><details>
            <summary style="cursor: pointer"><%= Enum.count(@hierachy_missing)%></summary>
            <ul>
            <%= for i <- @hierachy_missing do %>
              <li><%= i.id %></li>
              <% end %>
          </ul>
          </details></dd>
            <dt style="margin: 0">Invalid Parenthoods</dt>
            <dd style="margin: 0">
          <details>
            <summary style="cursor: pointer"><%= Enum.count(@hierachy_invalid)%></summary>
            <ul>
            <%= for i <- @hierachy_invalid do %>
              <li><%= i.id %></li>
              <% end %>
          </ul>
          </details></dd>
          <dt></dt>
          <dd style="margin: 0"><button type="button" phx-click="repair_hierarchy"  style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff">Repair</button></dd>
          </dl>

        </div>
      <h3>Element Tree</h3>

      <div style="display: flex; gap: 1ex; padding: 1ex 0">
        <button type="button" phx-click="create_group"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Group</button>
        <button type="button" phx-click="create_text"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Text</button>
        <button type="button" phx-click="create_box"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Box</button>
        <button type="button" phx-click="create_edge"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Line</button>
      </div>

      <.live_component id={"hierarchy-list"} module={RenewCollabWeb.HierarchyListComponent} document={@document} symbols={@symbols} selection={@selection} symbols={@symbols} />
    </div>
    <h2>History</h2>
    <div style="display: flex; gap: 0.5ex">
      <%= if @undo_redo.predecessor_id == @undo_redo.id do %>
      <button style="cursor: pointer;padding: 1ex; border: none; background: #aaa; color: #fff" disabled >Undo</button>
      <% else %>
      <button style="cursor: pointer;padding: 1ex; border: none; background: #333; color: #fff"  phx-click="restore" phx-value-id={@undo_redo.predecessor_id}>Undo</button>
      <% end %>
    <%= case @undo_redo.successors do %>
    <%[] ->  %><button style="padding: 1ex; border: none; background: #aaa; color: #fff" disabled>Redo</button>
    <%[a] ->  %>
     <%= if a.id == @undo_redo.id do %>
      <button style="cursor: pointer;padding: 1ex; border: none; background: #aaa; color: #fff" disabled >Redo</button>
      <% else %>
      <button style="cursor: pointer;padding: 1ex; border: none; background: #333; color: #fff"  phx-click="restore" phx-value-id={a.id}>Redo</button>
      <% end %>

    <% more ->  %>
    <div style="display: flex; flex-direction: column; gap: 0.5ex">
      <%= for a <- more, a.id != @undo_redo.id do %>
    <button style="cursor: pointer;padding: 1ex; border: none; background: #333; color: #fff" phx-click="restore" phx-value-id={a.id}>Redo</button>
    <% end%>
    </div>
    <% end%>
    </div>

              <h2 style="cursor: pointer; text-decoration: underline" phx-click="toggle-snapshots">Snapshots</h2>

      <div hidden={not @show_snapshots}>
        <button type="button" phx-click="create_snapshot"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Snaphot</button>
        <div style="width: 40vw">
          <%= for {day, snaps} <- @snapshots |> Enum.group_by(&DateTime.to_date(&1.inserted_at)) do %>
      <h5 style="margin: 0;"><%= day|> Calendar.strftime("%Y-%m-%d")  %></h5>
      <ul style="margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 0.2ex">
        <%= for s <- snaps  do %>
          <li style="display: flex; align-items: center;gap: 1ex;">
          <%= if s.is_latest do %>
          <span style="width: max-content; display: inline; padding: 1ex; border: none; background: #33a; color: #fff">
            Current</span>
          <%= s.inserted_at |> Calendar.strftime("%H:%M:%S")  %>
          <% else %>
            <button  style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff" phx-click="restore" phx-value-id={s.id}>
            Restore</button><%= s.inserted_at |> Calendar.strftime("%H:%M:%S")  %>
          <% end %>
          </li>
        <% end %>
      </ul>
        <% end %>
        </div>
      </div>
      </div>
    </div>
    """
  end

  defp viewbox(document) do
    edge_points =
      document.layers
      |> Enum.map(& &1.edge)
      |> Enum.flat_map(fn
        nil ->
          []

        e ->
          [
            {e.source_x, e.source_y},
            {e.target_x, e.target_y}
            | e.waypoints |> Enum.map(fn %{position_x: x, position_y: y} -> {x, y} end)
          ]
      end)

    box_points =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.flat_map(fn
        nil ->
          []

        b ->
          [
            {b.position_x, b.position_y},
            {b.position_x + b.width, b.position_y},
            {b.position_x + b.width, b.position_y + b.height},
            {b.position_x, b.position_y + b.height}
          ]
      end)

    text_points =
      document.layers
      |> Enum.map(& &1.text)
      |> Enum.flat_map(fn
        nil ->
          []

        b ->
          [
            {b.position_x, b.position_y},
            {b.position_x,
             b.position_y +
               (get_in(b, [Access.key(:style, %{}), Access.key(:font_size, %{})]) || 12) / 2 *
                 (b.body
                  |> String.split("\n")
                  |> Enum.filter(&(not blank?(&1)))
                  |> Enum.count())},
            {b.position_x +
               (get_in(b, [Access.key(:style, %{}), Access.key(:font_size, %{})]) || 12) / 2 *
                 (b.body
                  |> String.split("\n")
                  |> Enum.map(&String.length(&1))
                  |> Enum.max()), b.position_y}
          ]
      end)

    points = Enum.concat([text_points, edge_points, box_points])

    {{min_viewbox_x, _}, {max_viewbox_x, _}} =
      points |> Enum.min_max_by(&elem(&1, 0), fn -> {{0, 0}, {0, 0}} end)

    {{_, min_viewbox_y}, {_, max_viewbox_y}} =
      points |> Enum.min_max_by(&elem(&1, 1), fn -> {{0, 0}, {0, 0}} end)

    padding = 100

    [
      min_viewbox_x - padding,
      min_viewbox_y - padding,
      max_viewbox_x - min_viewbox_x + 2 * padding,
      max_viewbox_y - min_viewbox_y + 2 * padding
    ]
    |> Enum.map(&round(&1))
    |> Enum.join(" ")
  end

  def handle_event("toggle_visible", %{"id" => id}, socket) do
    Renew.toggle_visible(socket.assigns.document.id, id)

    {:noreply, socket}
  end

  def handle_event("toggle-hierarchy", %{}, socket) do
    {:noreply, socket |> update(:show_hierarchy, &(not &1))}
  end

  def handle_event("toggle-snapshots", %{}, socket) do
    {:noreply, socket |> update(:show_snapshots, &(not &1))}
  end

  def handle_event("update-viewbox", %{}, socket) do
    {:noreply,
     socket
     |> assign(:viewbox, viewbox(socket.assigns.document))}
  end

  def handle_event("repair_hierarchy", %{}, socket) do
    RenewCollab.RenewHierarchy.repair_parenthood(socket.assigns.document.id)

    {:noreply,
     socket
     |> assign(
       :hierachy_missing,
       RenewCollab.RenewHierarchy.find_missing(socket.assigns.document.id)
     )
     |> assign(
       :hierachy_invalid,
       RenewCollab.RenewHierarchy.find_invalids(socket.assigns.document.id)
     )
     |> assign(:document, Renew.get_document_with_elements!(socket.assigns.document.id))
     |> assign(:snapshots, Versioning.document_versions(socket.assigns.document.id))
     |> assign(:undo_redo, Versioning.document_undo_redo(socket.assigns.document.id))}
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
          "value" => color
        },
        socket
      ) do
    Renew.update_layer_style(
      socket.assigns.document.id,
      layer_id,
      Renew.layer_style_key(style_attr),
      color
    )

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "edge",
          "style" => style_attr,
          "value" => color
        },
        socket
      ) do
    Renew.update_layer_edge_style(
      socket.assigns.document.id,
      layer_id,
      Renew.layer_edge_style_key(style_attr),
      color
    )

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "text",
          "style" => style_attr,
          "value" => color
        },
        socket
      ) do
    Renew.update_layer_text_style(
      socket.assigns.document.id,
      layer_id,
      Renew.layer_text_style_key(style_attr),
      color
    )

    {:noreply, socket}
  end

  def handle_event("update_text_body", %{"layer_id" => layer_id, "value" => new_body}, socket) do
    Renew.update_layer_text_body(
      socket.assigns.document.id,
      layer_id,
      new_body
    )

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
    Renew.update_layer_box_size(
      socket.assigns.document.id,
      layer_id,
      new_size
    )

    {:noreply, socket}
  end

  def handle_event(
        "update_text_position",
        %{
          "layer_id" => layer_id,
          "value" =>
            %{
              "position_x" => position_x,
              "position_y" => position_y
            } = new_position
        },
        socket
      ) do
    Renew.update_layer_text_position(
      socket.assigns.document.id,
      layer_id,
      new_position
    )

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
    Renew.update_layer_edge_position(
      socket.assigns.document.id,
      layer_id,
      new_position
    )

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
    Renew.update_layer_z_index(
      socket.assigns.document.id,
      layer_id,
      new_z_index
    )

    {:noreply, socket}
  end

  def handle_event(
        "update_waypoint_position",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id,
          "value" =>
            %{
              "position_x" => position_x,
              "position_y" => position_y
            } = new_position
        },
        socket
      ) do
    Renew.update_layer_edge_waypoint_position(
      socket.assigns.document.id,
      layer_id,
      waypoint_id,
      new_position
    )

    {:noreply, socket}
  end

  def handle_event(
        "delete_waypoint",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_d
        },
        socket
      ) do
    Renew.delete_layer_edge_waypoint(
      socket.assigns.document.id,
      layer_id,
      waypoint_d
    )

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => after_waypoint_id,
          "position_x" => position_x,
          "position_y" => position_y
        },
        socket
      ) do
    Renew.create_layer_edge_waypoint(
      socket.assigns.document.id,
      layer_id,
      after_waypoint_id,
      {position_x, position_y}
    )

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => after_waypoint_id
        },
        socket
      ) do
    Renew.create_layer_edge_waypoint(
      socket.assigns.document.id,
      layer_id,
      after_waypoint_id
    )

    {:noreply, socket}
  end

  def handle_event(
        "clear_waypoints",
        %{
          "layer_id" => layer_id
        },
        socket
      ) do
    Renew.remove_all_layer_edge_waypoints(
      socket.assigns.document.id,
      layer_id
    )

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
    Renew.update_layer_semantic_tag(
      socket.assigns.document.id,
      layer_id,
      new_tag
    )

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
    Renew.update_layer_box_shape(
      socket.assigns.document.id,
      layer_id,
      shape_id,
      shape_attributes
    )

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
    Renew.move_layer(
      socket.assigns.document.id,
      layer_id,
      target_layer_id,
      Renew.parse_hierarchy_position(order, relative)
    )

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
    Renew.move_layer_relative(
      socket.assigns.document.id,
      layer_id,
      dx,
      dy
    )

    {:noreply, socket}
  end

  def handle_event(
        "delete_layer",
        %{"id" => layer_id},
        socket
      ) do
    Renew.delete_layer(
      socket.assigns.document.id,
      layer_id
    )

    {:noreply, socket}
  end

  def handle_event(
        "create_group",
        %{},
        socket
      ) do
    Renew.create_layer(socket.assigns.document.id)
    {:noreply, socket}
  end

  def handle_event(
        "create_text",
        %{},
        socket
      ) do
    Renew.create_layer(socket.assigns.document.id, %{
      "text" => %{
        "position_x" => 0,
        "position_y" => 0,
        "body" => "Hello World"
      }
    })

    {:noreply, socket}
  end

  def handle_event(
        "create_box",
        %{},
        socket
      ) do
    Renew.create_layer(socket.assigns.document.id, %{
      "box" => %{
        "position_x" => 0,
        "position_y" => 0,
        "width" => 200,
        "height" => 100
      }
    })

    {:noreply, socket}
  end

  def handle_event(
        "create_edge",
        %{},
        socket
      ) do
    Renew.create_layer(socket.assigns.document.id, %{
      "edge" => %{
        "source_x" => 0,
        "source_y" => 0,
        "target_x" => 200,
        "target_y" => 100
      }
    })

    {:noreply, socket}
  end

  def handle_event(
        "create_snapshot",
        %{},
        socket
      ) do
    Versioning.create_snapshot(socket.assigns.document.id)

    {:noreply, socket}
  end

  def handle_event(
        "restore",
        %{"id" => id},
        socket
      ) do
    Versioning.restore_snapshot(socket.assigns.document.id, id)

    {:noreply, socket}
  end

  def handle_info({:document_changed, document_id}, socket) do
    if document_id == socket.assigns.document.id do
      {:noreply,
       socket
       |> assign(
         :document,
         Renew.get_document_with_elements!(document_id)
       )
       |> assign(:snapshots, Versioning.document_versions(document_id))
       |> assign(:undo_redo, Versioning.document_undo_redo(document_id))}
    end
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()
end
