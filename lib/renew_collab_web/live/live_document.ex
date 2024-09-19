defmodule RenewCollabWeb.LiveDocument do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Renew
  alias RenewCollab.Symbol

  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(:document, Renew.get_document_with_elements!(id))
      |> assign(:hierachy_missing, RenewCollab.RenewHierarchy.find_missing(id))
      |> assign(:hierachy_invalid, RenewCollab.RenewHierarchy.find_invalids(id))
      |> assign(:selection, nil)
      |> assign(:symbols, Symbol.list_shapes() |> Enum.map(fn s -> {s.id, s} end) |> Map.new())

    RenewCollabWeb.Endpoint.subscribe("redux_document:#{id}")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid;width: 100%; grid-template-rows: auto 1fr;">
      <.link href={~p"/live/documents"}>Back</.link>
      <h2><%= @document.name %></h2>
      <svg id={"document-#{@document.id}"} viewBox={viewbox(@document)} style="display: block;" width="1000" height="1000">
        <%= for layer <- @document.layers, layer.direct_parent == nil do %> 
          <.live_component selectable={true} id={layer.id} module={RenewCollabWeb.HierarchyLayerComponent} document={@document} layer={layer} selection={@selection} selected={@selection == layer.id} symbols={@symbols} />
        <% end %>
      </svg>

      <div style="position: fixed; width: 40em; right: 0; top: 0; bottom: 0; overflow: auto;">
        <h2>Hierarchy</h2>
        <div>
          <dl style="display: grid; grid-template-columns: auto auto; justify-content: start; gap: 1ex 1em">
            <dt style="margin: 0">Missing Parenthoods</dt>
            <dd style="margin: 0"><%= Enum.count(@hierachy_missing)%></dd>
            <dt style="margin: 0">Invalid Parenthoods</dt>
            <dd style="margin: 0"><%= Enum.count(@hierachy_invalid)%></dd>
          </dl>

          <button type="button" phx-click="repair_hierarchy">Repair</button>
        </div>

      <.live_component id={"hierarchy-list"} module={RenewCollabWeb.HierarchyListComponent} document={@document} symbols={@symbols} selection={@selection} symbols={@symbols} />

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
               b.style.font_size / 2 *
                 (b.body
                  |> String.split("\n")
                  |> Enum.filter(&(not blank?(&1)))
                  |> Enum.count())},
            {b.position_x +
               b.style.font_size / 2 *
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
     |> assign(:document, Renew.get_document_with_elements!(socket.assigns.document.id))}
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
          "target_layer_id" => target_layer_id,
          "layer_id" => layer_id,
          "relative" => relative
        },
        socket
      ) do
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

  def handle_info({:document_changed, document_id}, socket) do
    if document_id == socket.assigns.document.id do
      {:noreply,
       socket
       |> update(:document, fn _ ->
         Renew.get_document_with_elements!(document_id)
       end)}
    end
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()
end
