defmodule RenewCollabWeb.LayerPropertiesComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div style="display: flex; padding: 1ex; gap: 0.5ex">
        <small>
          <button
            style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
            phx-click="select_layer"
            phx-value-id="-"
          >
            unselect
          </button>
        </small>
        <br />
        <small>
          <button
            style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
            phx-click="delete_layer"
            phx-value-id={@layer.id}
          >
            delete
          </button>
        </small>
        <br />
      </div>

      <fieldset>
        <legend><label for={"semantic-tag-#{@layer.id}"}>Semantic Tag</label></legend>

        <input
          phx-hook="RenewSemanticTag"
          id={"semantic-tag-#{@layer.id}"}
          type="text"
          value={@layer.semantic_tag}
          style="width: 100%; box-sizing: border-box"
          rnw-layer-id={"#{@layer.id}"}
          list="all-semantic-tags"
        />
      </fieldset>

      <%= if @layer.outgoing_link do %>
        <button phx-click="unlink_layer" phx-value-id={@layer.id} type="button">unlink</button>
      <% else %>
        <form phx-hook="RnwLinkLayer" rnw-layer-id={"#{@layer.id}"} id={"link-layer-#{@layer.id}"}>
          <select style="width: 5em" name="target">
            <option value="">Target</option>

            <%= for l <- @document.layers do %>
              <option value={l.id}><%= l.semantic_tag %>/<%= l.id %></option>
            <% end %>
          </select>
        </form>
      <% end %>

      <input
        style="width: 3em"
        style="padding:0.5ex"
        type="number"
        step="1"
        min="0"
        phx-hook="RenewZIndex"
        id={"layer-zindex-#{@layer.id}"}
        rnw-layer-id={"#{@layer.id}"}
        value={@layer.z_index}
        size="2"
        width="30"
      />
      <%= unless is_nil(@layer.box) do %>
        <fieldset>
          <legend>Box Size</legend>

          <form
            phx-hook="RenewBoxSize"
            id={"layer-box-size-#{@layer.id}"}
            rnw-layer-id={"#{@layer.id}"}
          >
            <dl style="display: grid; grid-template-columns: max-content 1fr; gap: 0.5em">
              <dt>X</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="position_x"
                  value={@layer.box.position_x}
                />
              </dd>

              <dt>Y</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="position_y"
                  value={@layer.box.position_y}
                />
              </dd>

              <dt>Width</dt>

              <dd style="margin: 0">
                <input style="padding:0.5ex" type="number" name="width" value={@layer.box.width} />
              </dd>

              <dt>Height</dt>

              <dd style="margin: 0">
                <input style="padding:0.5ex" type="number" name="height" value={@layer.box.height} />
              </dd>
            </dl>
          </form>
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.box) and is_nil(@layer.text) do %>
        <fieldset>
          <legend for={"layer-interface-#{@layer.id}"}>Interface</legend>

          <%= if false && @layer.interface do %>
            <span style="display: inline-flex; align-items: baseline;gap: 1ex;  padding: 0.5ex 1ex; background: #333; color: #fff">
              <span>
                <%= @layer.interface.socket_schema.name %>
              </span>

              <button
                phx-click="remove_layer_socket_schema"
                phx-value-layer_id={@layer.id}
                type="button"
                style="text-align: center; align-self: center; cursor: pointer; border: none; background: #333; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 100%; font-weight: bold;"
                title="Remove Interface"
              >
                &times;
              </button>
            </span>
          <% else %>
            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
              <select
                phx-hook="RnwAssignInterface"
                rnw-layer-id={"#{@layer.id}"}
                id={"layer-interface-#{@layer.id}"}
                name="socket_schema_id"
              >
                <option value="" {if(is_nil(@layer.interface), do: [selected: "selected"], else: [])}>
                  ---
                </option>

                <%= for {_sid, s} <- socket_schemas do %>
                  <option
                    value={s.id}
                    {if(@layer.interface && s.id == @layer.interface.socket_schema_id, do: [selected: "selected"], else: [])}
                  >
                    <%= s.name %>
                  </option>
                <% end %>
              </select>
              <% else _ -> %>
                Loading
            <% end %>
          <% end %>
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.box) do %>
        <fieldset>
          <legend>Shape</legend>

          <form
            phx-hook="RenewBoxShape"
            id={"layer-box-shape-#{@layer.id}"}
            rnw-layer-id={"#{@layer.id}"}
          >
            <dl style="display: grid; grid-template-columns: max-content 1fr; gap: 0.5em">
              <dt>Symbol</dt>

              <dd style="margin: 0">
                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                  <select name="shape_id">
                    <option
                      {if(is_nil(@layer.box.symbol_shape_id), do: [selected: "selected"], else: [])}
                      value=""
                    >
                      ---
                    </option>

                    <%= for {id, symbol} <- symbols |> Enum.sort_by(&(elem(&1, 1).name)) do %>
                      <option
                        value={id}
                        {if(id == @layer.box.symbol_shape_id, do: [selected: "selected"], else: [])}
                      >
                        <%= symbol.name %>
                      </option>
                    <% end %>
                  </select>
                  <% else _ -> %>
                    Loading...
                <% end %>
              </dd>

              <dt>
                Attributes
              </dt>

              <dd style="margin: 0">
                <textarea name="shape_attributes"><%=
               @layer.box.symbol_shape_attributes |> Jason.encode() |> elem(1)
                %></textarea>
              </dd>
            </dl>
          </form>
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.edge) do %>
        <fieldset>
          <legend>Edge Path</legend>

          <form
            phx-hook="RenewEdgePosition"
            id={"layer-edge-position-#{@layer.id}"}
            rnw-layer-id={"#{@layer.id}"}
          >
            <dl style="display: grid; grid-template-columns: max-content 1fr; gap: 0.5em">
              <dt>Source X</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="source_x"
                  value={@layer.edge.source_x}
                />
              </dd>

              <dt>Source Y</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="source_y"
                  value={@layer.edge.source_y}
                />
              </dd>

              <dt>Target X</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="target_x"
                  value={@layer.edge.target_x}
                />
              </dd>

              <dt>Target Y</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="target_y"
                  value={@layer.edge.target_y}
                />
              </dd>
            </dl>
          </form>

          <ul>
            <li>
              <button
                phx-hook="RenewEdgeWaypointCreate"
                id={"layer-edge-position-#{@layer.id}-waypoint-new"}
                rnw-layer-id={"#{@layer.id}"}
                type="button"
              >
                +
              </button>

              <button
                phx-hook="RenewEdgeWaypointsClear"
                id={"layer-edge-position-#{@layer.id}-waypoints-clear"}
                rnw-layer-id={"#{@layer.id}"}
                type="button"
              >
                Clear
              </button>
            </li>

            <%= for w <- @layer.edge.waypoints do %>
              <li>
                <small style="white-space: nowrap;"><%= w.sort %> - <%= w.id %></small> <br />
                <form
                  style="display: inline"
                  phx-hook="RenewEdgeWaypointPosition"
                  id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}"}
                  rnw-layer-id={"#{@layer.id}"}
                  rnw-waypoint-id={"#{w.id}"}
                >
                  <input
                    style="padding:0.5ex"
                    type="number"
                    name="position_x"
                    value={w.position_x}
                    size="4"
                  />
                  <input
                    style="padding:0.5ex"
                    type="number"
                    name="position_y"
                    value={w.position_y}
                    size="4"
                  />
                </form>

                <button
                  phx-hook="RenewEdgeWaypointDelete"
                  id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}-delete"}
                  rnw-layer-id={"#{@layer.id}"}
                  rnw-waypoint-id={"#{w.id}"}
                  type="button"
                >
                  X
                </button>
              </li>

              <li>
                <button
                  phx-hook="RenewEdgeWaypointCreate"
                  id={"layer-edge-position-#{@layer.id}-waypoint-#{w.id}-new"}
                  rnw-layer-id={"#{@layer.id}"}
                  rnw-waypoint-id={"#{w.id}"}
                  type="button"
                >
                  +
                </button>
              </li>
            <% end %>
          </ul>
        </fieldset>

        <fieldset>
          <legend>Bonds</legend>

          <dl>
            <dt>Source Bond</dt>

            <dd>
              <%= if @layer.edge.source_bond do %>
                <small
                  phx-click="select_layer"
                  phx-value-id={@layer.edge.source_bond.layer_id}
                  style="display: inline-block; cursor: pointer; background: #333; color: #fff"
                >
                  <%= @layer.edge.source_bond.layer_id %>/<br /> <%= @layer.edge.source_bond.socket_id %>
                </small>
                <br />
                <button
                  phx-click="detach-bond"
                  phx-value-id={@layer.edge.source_bond.id}
                  type="button"
                >
                  Detach
                </button>
              <% else %>
                <form
                  phx-hook="RnwEdgeBond"
                  rnw-edge-id={"#{@layer.edge.id}"}
                  rnw-kind="source"
                  id={"form-attach-bond-source-#{@layer.id}"}
                >
                  <select style="width: 5em" name="layer_id">
                    <option value="">Layer</option>

                    <%= for l <- @document.layers, not is_nil(l.box) do %>
                      <option value={l.id}><%= l.semantic_tag %>/<%= l.id %></option>
                    <% end %>
                  </select>

                  <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
                    <select style="width: 5em" name="socket_id">
                      <option value="">Socket</option>

                      <%= for {_sid, schema} <- socket_schemas do %>
                        <optgroup label={schema.name}>
                          <%= for sock <- schema.sockets do %>
                            <option value={sock.id}><%= sock.name %></option>
                          <% end %>
                        </optgroup>
                      <% end %>
                    </select>
                    <% else _ -> %>
                      Loading
                  <% end %>
                  <button type="submit">Attach</button>
                </form>
              <% end %>
            </dd>

            <dt>Target Bond</dt>

            <dd>
              <%= if @layer.edge.target_bond do %>
                <small
                  phx-click="select_layer"
                  phx-value-id={@layer.edge.target_bond.layer_id}
                  style="display: inline-block; cursor: pointer; background: #333; color: #fff"
                >
                  <%= @layer.edge.target_bond.layer_id %>/<br /> <%= @layer.edge.target_bond.socket_id %>
                </small>
                <br />
                <button
                  phx-click="detach-bond"
                  phx-value-id={@layer.edge.target_bond.id}
                  type="button"
                >
                  Detach
                </button>
              <% else %>
                <form
                  phx-hook="RnwEdgeBond"
                  rnw-edge-id={"#{@layer.edge.id}"}
                  rnw-kind="target"
                  id={"form-attach-bond-target-#{@layer.id}"}
                >
                  <select style="width: 5em" name="layer_id">
                    <option value="">Layer</option>

                    <%= for l <- @document.layers, not is_nil(l.box) do %>
                      <option value={l.id}><%= l.semantic_tag %>/<%= l.id %></option>
                    <% end %>
                  </select>

                  <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
                    <select style="width: 5em" name="socket_id">
                      <option value="">Socket</option>

                      <%= for {_sid, schema} <- socket_schemas do %>
                        <optgroup label={schema.name}>
                          <%= for sock <- schema.sockets do %>
                            <option value={sock.id}><%= sock.name %></option>
                          <% end %>
                        </optgroup>
                      <% end %>
                    </select>
                    <% else _ -> %>
                      Loading
                  <% end %>
                  <button type="submit">Attach</button>
                </form>
              <% end %>
            </dd>
          </dl>
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.text) do %>
        <fieldset>
          <legend>Text Position</legend>

          <form
            phx-hook="RenewTextPosition"
            id={"layer-text-position-#{@layer.id}"}
            rnw-layer-id={"#{@layer.id}"}
          >
            <dl style="display: grid; grid-template-columns: max-content 1fr; gap: 0.5em">
              <dt>X</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="position_x"
                  value={@layer.text.position_x}
                />
              </dd>

              <dt>Y</dt>

              <dd style="margin: 0">
                <input
                  style="padding:0.5ex"
                  type="number"
                  name="position_y"
                  value={@layer.text.position_y}
                />
              </dd>
            </dl>
          </form>
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.text) do %>
        <fieldset>
          <legend>Text</legend>
          <textarea
            rows="5"
            cols="30"
            phx-hook="RenewTextBody"
            id={"layer-text-body-#{@layer.id}"}
            rnw-layer-id={"#{@layer.id}"}
          ><%= @layer.text.body %></textarea>
        </fieldset>
      <% end %>

      <fieldset>
        <legend>Layer Style</legend>

        <.live_component
          id={"layer-styles-#{@layer.id}"}
          attrs={[
            opacity: :number,
            background_color: :color,
            border_color: :color,
            border_width: :number,
            border_dash_array: :text
          ]}
          symbols={@symbols}
          element={@layer}
          element_type="layer"
          module={RenewCollabWeb.HierarchyStyleList}
          layer={@layer}
        />
      </fieldset>

      <%= unless is_nil(@layer.edge) do %>
        <fieldset>
          <legend>Edge Style</legend>

          <.live_component
            id={"edge-styles-#{@layer.id}"}
            attrs={[
              stroke_width: :number,
              stroke_color: :color,
              stroke_join: :text,
              stroke_cap: :text,
              stroke_dash_array: :text,
              smoothness: :text,
              source_tip_symbol_shape_id: :symbol,
              target_tip_symbol_shape_id: :symbol
            ]}
            symbols={@symbols}
            element={@layer.edge}
            element_type="edge"
            module={RenewCollabWeb.HierarchyStyleList}
            layer={@layer}
          />
        </fieldset>
      <% end %>

      <%= unless is_nil(@layer.text) do %>
        <fieldset>
          <legend>Text Style</legend>

          <.live_component
            id={"text-styles-#{@layer.id}"}
            attrs={[
              bold: :checkbox,
              italic: :checkbox,
              underline: :checkbox,
              alignment: :text,
              font_size: :number,
              font_family: :text,
              text_color: :color,
              rich: :checkbox,
              blank_lines: :checkbox
            ]}
            symbols={@symbols}
            element={@layer.text}
            element_type="text"
            module={RenewCollabWeb.HierarchyStyleList}
            layer={@layer}
          />
        </fieldset>
      <% end %>
    </div>
    """
  end
end
