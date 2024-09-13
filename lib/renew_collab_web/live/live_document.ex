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

    RenewCollabWeb.Endpoint.subscribe("document:#{id}")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid;width: 100%; grid-template-rows: auto 1fr;">
      <.link href={~p"/live/documents"}>Back</.link>
      <h2><%= @document.name %></h2>
      <svg id={"document-#{@document.id}"} viewBox={viewbox(@document)} style="display: block;" width="1000" height="1000">
        <%= for layer <- @document.layers, layer.direct_parent == nil do %> 
          <.live_component id={layer.id} module={RenewCollabWeb.HierarchyLayerComponent} document={@document} layer={layer} selection={@selection} selected={@selection == layer.id} symbols={@symbols} />
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

      <.live_component id={"hierarchy-list"} module={RenewCollabWeb.HierarchyListComponent} document={@document} selection={@selection} symbols={@symbols} />

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

    points = Enum.concat(edge_points, box_points)

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
    Renew.toggle_visible(id)

    RenewCollabWeb.Endpoint.broadcast!(
      "document:#{socket.assigns.document.id}",
      "layer:update",
      %{"id" => id}
    )

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
          "style" => "background_color",
          "value" => color
        },
        socket
      ) do
    Renew.update_layer_style(socket.assigns.document.id, layer_id, :background_color, color)

    RenewCollabWeb.Endpoint.broadcast!(
      "document:#{socket.assigns.document.id}",
      "layer:update",
      %{"id" => layer_id}
    )

    {:noreply, socket}
  end

  def handle_info(%{topic: <<"document:", doc_id::binary>>, payload: state}, socket) do
    if doc_id == socket.assigns.document.id do
      {:noreply,
       socket
       |> update(:document, fn _ ->
         Renew.get_document_with_elements!(socket.assigns.document.id)
       end)}
    end
  end
end
