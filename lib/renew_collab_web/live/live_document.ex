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

      <table border="1" cellspacing="0" cellpadding="5">
        <thead>
          <tr>
            <td width="20" align="center">Vis</td>
            <td width="20" align="center">Box</td>
            <td width="20" align="center">Text</td>
            <td width="20" align="center">Edge</td>
            <td width="20" align="right">Ord.</td>
            <td>
              ID/Type
            </td>
          </tr>
        </thead>
        <tbody>
        <.live_component id={"hierarchy-list"} module={RenewCollabWeb.HierarchyListComponent} document={@document} selection={@selection} symbols={@symbols} />

      </tbody>
      </table>
      </div>
    </div>
    """
  end

  defp viewbox(document) do
    min_viewbox_x =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> min(acc, b.position_x)
      end)

    min_viewbox_y =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> min(acc, b.position_y)
      end)

    max_viewbox_x =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> max(acc, b.position_x + b.width)
      end)

    max_viewbox_y =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> max(acc, b.position_y + b.height)
      end)

    [min_viewbox_x - 200, min_viewbox_y - 200, max_viewbox_x + 400, max_viewbox_y + 400]
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
