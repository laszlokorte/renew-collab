defmodule RenewCollabWeb.HierarchyRowComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <tr id={"layer-list-item-#{@layer.id}"} bgcolor={if(@selected, do: "#ffaaff", else: "white")}>
        <td width="20" align="center" style="cursor:pointer;" phx-click="toggle_visible" phx-value-id={@layer.id}><%= if @layer.hidden do %><% else %>👁<% end %></td>
        <td width="20">          <%= if @layer.outgoing_link do %><span style="cursor: pointer" phx-click="select_layer" phx-value-id={@layer.outgoing_link.target_layer_id}>🔗</span><% end %></td>
        <td width="20" align="center"><%= if @layer.box do %>☐<% end %></td>
        <td width="20" align="center">
          <%= if @layer.text do %>
          T
          <% end %>
        </td>
        <td width="20" align="center">
          <%= if not (is_nil(@layer.edge) or is_nil(@layer.edge.style)) do %>
          <%= if @layer.edge.style.source_tip_symbol_shape_id do %>
            &lt;
          <% end %>
          <% end %>
          <%= if @layer.edge do %>&mdash;<% end %>
          <%= if not (is_nil(@layer.edge) or is_nil(@layer.edge.style)) do %>
          <%= if @layer.edge.style.target_tip_symbol_shape_id do %>
            &gt;
          <% end %>
          <% end %>
        </td>
        <td width="20" align="right" style="white-space: nowrap; word-wrap: none">
          <%= if @selected do %>
          <input style="width: 3em" type="number" step="1" min="0"  phx-hook="RenewZIndex"  id={"layer-zindex-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"} value={@layer.z_index} size="2" width="30" />
          <%= else%>
          <%= @layer.z_index %>
          <%= end%>
        </td>
        <td style={"padding-left: #{0.2+ 2*@depth}em"}>
            <div draggable="true" phx-hook="RenewGrabber" id={"layer-grab-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"} style="user-select: none; cursor: grab; padding: 2px; background: black; color: white; display: grid; grid-template-rows: 1fr 1fr; grid-template-columns: 1fr 1fr; width: 2em">
              <div  phx-hook="RenewDropper" id={"dropper-#{@layer.id}-below-outside"} rnw-layer-id={"#{@layer.id}"} rnw-order="below" rnw-relative="outside" style="grid-row: 1 / span 1; grid-column: 1/span 1; min-height: 1em"></div>
              <div  phx-hook="RenewDropper" id={"dropper-#{@layer.id}-above-outside"} rnw-layer-id={"#{@layer.id}"} rnw-order="above" rnw-relative="outside" style="grid-row: 2 / span 1; grid-column: 1/span 1; min-height: 1em"></div>
              <div  phx-hook="RenewDropper" id={"dropper-#{@layer.id}-below-inside"} rnw-layer-id={"#{@layer.id}"} rnw-order="below" rnw-relative="inside" style="grid-row: 1 / span 1; grid-column: 2/span 1; min-width: 1em"></div>
              <div  phx-hook="RenewDropper" id={"dropper-#{@layer.id}-above-inside"} rnw-layer-id={"#{@layer.id}"} rnw-order="above" rnw-relative="inside" style="grid-row: 2 / span 1; grid-column: 2/span 1; min-width: 1em"></div>
              <div style="pointer-events: none; grid-row: 1 / span 2; grid-column: 1/span 1; grid-column: 1/span 2; text-align: center; align-self: center;">☰</div>

            </div>
        </td>
        <td style={"padding-left: #{0.2+ 2*@depth}em"} {unless(@selected, do: [style: "cursor: pointer;", "phx-click": "select_layer"], else: [])} phx-value-id={@layer.id}>
          <%= if @selected do %>
          <small><button phx-click="select_layer" phx-value-id={"-"}>unselect</button></small><br>
          <small><button phx-click="delete_layer" phx-value-id={@layer.id}>delete</button></small><br>
          <% end %>

          <small><code><%= @layer.id %></code></small><br>
          
            <%= if @selected do %>
            <input  phx-hook="RenewSemanticTag" id={"semantic-tag-#{@layer.id}"}  type="text" value={@layer.semantic_tag} style="width: 100%; box-sizing: border-box"  rnw-layer-id={"#{@layer.id}"} />
            <% else %>
            <small><code><%= @layer.semantic_tag %></code></small>
            <% end %>

          <%= if @selected do %>
          <%= unless is_nil(@layer.box) do %>
          <fieldset>
            <legend>Box Size</legend>
            <form phx-hook="RenewBoxSize" id={"layer-box-size-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"}>
              <dl>
                <dt>X</dt>
                <dd><input type="number" name="position_x" value={@layer.box.position_x} /></dd>
                <dt>Y</dt>
                <dd><input type="number" name="position_y" value={@layer.box.position_y} /></dd>
                <dt>Width</dt>
                <dd><input type="number" name="width" value={@layer.box.width} /></dd>
                <dt>Height</dt>
                <dd><input type="number" name="height" value={@layer.box.height} /></dd>
              </dl>
            </form>
          </fieldset>
          <% end %>
          <%= unless is_nil(@layer.box) do %>
          <fieldset>
            <legend>Shape</legend>
            <form phx-hook="RenewBoxShape" id={"layer-box-shape-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"}>
               <dl>
                <dt>X</dt>
                <dd>
               <select name="shape_id">
                <option {if(is_nil(@layer.box.symbol_shape_id), do: [selected: "selected"], else: [])} value="">---</option>
                 <%= for {id, symbol} <- @symbols |> Enum.sort_by(&(elem(&1, 1).name)) do %>
                  <option value={id} {if(id == @layer.box.symbol_shape_id, do: [selected: "selected"], else: [])}><%= symbol.name %></option>
                  <% end %>
               </select>
             </dd>
             <dt>
               Attributes
             </dt>
             <dd>
               <textarea name="shape_attributes"></textarea>
             </dd>
           </dl>
            </form>
          </fieldset>
          <% end %>
          <%= unless is_nil(@layer.edge) do %>
          <fieldset>
            <legend>Edge Path</legend>
            <form phx-hook="RenewEdgePosition" id={"layer-edge-position-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"}>
              <dl>
                <dt>Source X</dt>
                <dd><input type="number" name="source_x" value={@layer.edge.source_x} /></dd>
                <dt>Source Y</dt>
                <dd><input type="number" name="source_y" value={@layer.edge.source_y} /></dd>
                <dt>Target X</dt>
                <dd><input type="number" name="target_x" value={@layer.edge.target_x} /></dd>
                <dt>Target Y</dt>
                <dd><input type="number" name="target_y" value={@layer.edge.target_y} /></dd>
              </dl>
            </form>
            <ul>
                <li>
                  <button phx-hook="RenewEdgeWaypointCreate"  id={"layer-edge-position-#{@layer.id}-waypoint-new"} rnw-layer-id={"#{@layer.id}"} type="button">+</button>

                  <button phx-hook="RenewEdgeWaypointsClear"  id={"layer-edge-position-#{@layer.id}-waypoints-clear"} rnw-layer-id={"#{@layer.id}"} type="button">Clear</button>
                </li>
              <%= for w <- @layer.edge.waypoints do %>
                <li>
                  <small style="white-space: nowrap;"><%= w.sort %> - <%= w.id %></small>
                  <br>
                  <form style="display: inline" phx-hook="RenewEdgeWaypointPosition" id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}"} rnw-layer-id={"#{@layer.id}"} rnw-waypoint-id={"#{w.id}"}>
                    <input type="number" name="position_x" value={w.position_x} size="4" />
                    <input type="number" name="position_y" value={w.position_y} size="4" />
                  </form>
                  <button phx-hook="RenewEdgeWaypointDelete"  id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}-delete"} rnw-layer-id={"#{@layer.id}"} rnw-waypoint-id={"#{w.id}"} type="button">X</button>
                </li>
                <li>
                  <button phx-hook="RenewEdgeWaypointCreate"  id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}-new"} rnw-layer-id={"#{@layer.id}"} rnw-waypoint-id={"#{w.id}"} type="button">+</button>
                </li>
              <% end %>
            </ul>
          </fieldset>
          <% end %>
          <%= unless is_nil(@layer.text) do %>
          <fieldset>
            <legend>Text Position</legend>
            <form phx-hook="RenewTextPosition" id={"layer-text-position-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"}>
              <dl>
                <dt>X</dt>
                <dd><input type="number" name="position_x" value={@layer.text.position_x} /></dd>
                <dt>Y</dt>
                <dd><input type="number" name="position_y" value={@layer.text.position_y} /></dd>
              </dl>
            </form>
          </fieldset>
          <% end %>
          <%= unless is_nil(@layer.text) do %>
          <fieldset>
            <legend>Text</legend>
            <textarea rows="5" cols="30" phx-hook="RenewTextBody" id={"layer-text-body-#{@layer.id}"} rnw-layer-id={"#{@layer.id}"}><%= @layer.text.body %></textarea>
          </fieldset>
          <% end %>
          <fieldset>
            <legend>Layer Style</legend>
            <%= for {attr, type} <- [
            opacity: :number,
            background_color: :color,
            border_color: :color,
            border_width: :number,
            border_dash_array: :text,
            ] do %>
            <.live_component value={style_or_default(@layer, attr)}  element="layer" id={"layer-style-#{@layer.id}-#{attr}"} module={RenewCollabWeb.HierarchyStyleField} layer={@layer} attr={attr} type={type}  />
            <% end %>
          </fieldset>
          <%= unless is_nil(@layer.edge) do %>
          <fieldset>
            <legend>Edge Style</legend>
            <%= for {attr, type} <- [
            stroke_width: :number,
            stroke_color: :color,
            stroke_join: :text,
            stroke_cap: :text,
            stroke_dash_array: :text,
            smoothness: :text
            ] do %>
            <.live_component value={style_or_default(@layer.edge, attr)}  element="edge" id={"edge-style-#{@layer.id}-#{attr}"} module={RenewCollabWeb.HierarchyStyleField} layer={@layer} attr={attr} type={type}  />
            <% end %>
          </fieldset>
          <% end %>
          <%= unless is_nil(@layer.text) do %>
          <fieldset>
            <legend>Text Style</legend>
            <%= for {attr, type} <- [
            bold: :checkbox,
            italic: :checkbox,
            underline: :checkbox,
            alignment: :text,
            font_size: :number,
            font_family: :text,
            text_color: :color,
            rich: :checkbox,
            blank_lines: :checkbox,
            ] do %>
            <.live_component value={style_or_default(@layer.text, attr)}  element="text" id={"text-style-#{@layer.id}-#{attr}"} module={RenewCollabWeb.HierarchyStyleField} layer={@layer} attr={attr} type={type}  />
            <% end %>
          </fieldset>
          <% end %>
          <% end %>
        </td>
      </tr>
    """
  end

  defp style_or_default(%{:style => nil}, style_key) do
    default_style(style_key)
  end

  defp style_or_default(%{:style => style}, style_key) do
    with %{^style_key => value} <- style do
      value
    else
      _ -> default_style(style_key)
    end
  end

  defp default_style(style_key), do: nil
end
