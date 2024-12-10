defmodule RenewCollabWeb.HierarchyRowComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <tr id={"layer-list-item-#{@layer.id}"} bgcolor={if(@selected, do: "#99ddff", else: "white")}>
      <td
        valign="top"
        width="20"
        align="center"
        style="cursor:pointer;"
        phx-click="toggle_visible"
        phx-value-id={@layer.id}
      >
        <%= if @layer.hidden do %>
        <% else %>
          👁
        <% end %>
      </td>

      <td valign="top" width="20">
        <%= if @layer.outgoing_link do %>
          <span
            style="cursor: pointer"
            phx-click="select_layer"
            phx-value-id={@layer.outgoing_link.target_layer_id}
          >
            🔗
          </span>
        <% end %>
      </td>

      <td
        valign="top"
        width="20"
        align="center"
        {[style: "cursor: pointer;", "phx-click": "select_layer"]}
        phx-value-id={@layer.id}
      >
        <%= if @layer.box do %>
          ☐
        <% end %>
      </td>

      <td
        valign="top"
        width="20"
        align="center"
        {[style: "cursor: pointer;", "phx-click": "select_layer"]}
        phx-value-id={@layer.id}
      >
        <%= if @layer.text do %>
          T
        <% end %>
      </td>

      <td
        valign="top"
        width="20"
        align="center"
        {[style: "cursor: pointer;", "phx-click": "select_layer"]}
        phx-value-id={@layer.id}
      >
        <%= if @layer.edge && @layer.edge.style do %>
          <%= case {@layer.edge.style.source_tip_symbol_shape_id, @layer.edge.style.target_tip_symbol_shape_id} do %>
            <% {nil, nil} -> %>
              -
            <% {_, nil} -> %>
              🠈
            <% {nil, _} -> %>
              🠊
            <% {_, _} -> %>
              🡘
          <% end %>
        <% else %>
          <%= if @layer.edge do %>
            -
          <% end %>
        <% end %>
      </td>

      <td valign="top" width="20" align="center" style="white-space: nowrap; word-wrap: none">
        {@layer.z_index}
      </td>

      <td valign="top" style={"padding-left: #{0.2+ 2*@depth}em"}>
        <div
          draggable="true"
          phx-hook="RenewGrabber"
          id={"layer-grab-#{@layer.id}"}
          rnw-layer-id={"#{@layer.id}"}
          style="user-select: none; cursor: grab; padding: 2px; background: black; color: white; display: grid; grid-template-rows: 1fr 1fr; grid-template-columns: 1fr 1fr; width: 2em"
        >
          <div
            phx-hook="RenewDropper"
            id={"dropper-#{@layer.id}-below-outside"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-order="below"
            rnw-relative="outside"
            style="grid-row: 1 / span 1; grid-column: 1/span 1; min-height: 1em"
          >
          </div>

          <div
            phx-hook="RenewDropper"
            id={"dropper-#{@layer.id}-above-outside"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-order="above"
            rnw-relative="outside"
            style="grid-row: 2 / span 1; grid-column: 1/span 1; min-height: 1em"
          >
          </div>

          <div
            phx-hook="RenewDropper"
            id={"dropper-#{@layer.id}-below-inside"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-order="below"
            rnw-relative="inside"
            style="grid-row: 1 / span 1; grid-column: 2/span 1; min-width: 1em"
          >
          </div>

          <div
            phx-hook="RenewDropper"
            id={"dropper-#{@layer.id}-above-inside"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-order="above"
            rnw-relative="inside"
            style="grid-row: 2 / span 1; grid-column: 2/span 1; min-width: 1em"
          >
          </div>

          <div style="pointer-events: none; grid-row: 1 / span 2; grid-column: 1/span 1; grid-column: 1/span 2; text-align: center; align-self: center;">
            ☰
          </div>
        </div>
      </td>

      <td
        valign="top"
        {[style: "cursor: pointer;padding-left: #{0.2+ 2*@depth}em", "phx-click": "select_layer"]}
        phx-value-id={@layer.id}
      >
        <small><code>{@layer.id}</code></small> <br />
        <small><code>{@layer.semantic_tag}</code></small>
      </td>
    </tr>
    """
  end
end
