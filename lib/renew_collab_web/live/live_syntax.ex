defmodule RenewCollabWeb.LiveSyntax do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Symbols
  alias RenewCollab.Syntax
  alias RenewCollab.Sockets

  @topic "syntax"

  @semantic_tags (for {class_name, _} <- Renewex.Grammar.new(11).hierarchy do
                    class_name
                  end)

  def semantic_tags(), do: @semantic_tags

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    {:ok, load_data(socket)}
  end

  def handle_info({_, _syntax_id}, socket) do
    {:noreply, load_data(socket)}
  end

  defp load_data(socket) do
    socket
    |> assign(:syntax_types, Syntax.find_all())
    |> assign(:create_form, to_form(%{"name" => nil}, as: :create_syntax))
    |> assign_async(
      [
        :symbols,
        :sockets
      ],
      fn ->
        {:ok,
         %{
           sockets: Sockets.all_socket_by_id(),
           symbols: Symbols.list_shapes() |> Enum.map(fn s -> {s.id, s} end) |> Map.new()
         }}
      end
    )
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header />
      <div style="padding: 1em">
        <h2 style="margin: 0;">Syntax Rules</h2>

        <.form for={@create_form} phx-change="validate" phx-submit="save">
          <div style="display: flex; gap: 1ex; align-items: stretch">
            <.input style="padding: 1ex" type="text" field={@create_form[:name]} />
            <button style="background: #333; color: #fff; padding: 1ex; border: none">Create</button>
          </div>
        </.form>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th
                style="border-bottom: 1px solid #333;"
                align="left"
                valign="top"
                width="1000"
                colspan="2"
              >
                Name
              </th>

              <th
                style="border-bottom: 1px solid #333;"
                align="left"
                valign="top"
                width="100"
                colspan="4"
              >
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@syntax_types) do %>
              <tr>
                <td colspan="6">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Syntax Rules defined yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for syntax <- @syntax_types do %>
                <tr {[style: "background-color:#333;color: #fff"]}>
                  <td colspan="2">
                    {syntax.name}

                    <%= if syntax.default do %>
                      (default)
                    <% else %>
                      <button
                        style="cursor: pointer; background: #048; color: #fff; padding: 1ex; border: none"
                        phx-click="make_default"
                        value={syntax.id}
                      >
                        Make default
                      </button>
                    <% end %>
                  </td>

                  <td width="50">
                    <button
                      style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                      type="button"
                      phx-click="delete_syntax"
                      value={syntax.id}
                    >
                      Delete
                    </button>
                  </td>
                </tr>

                <tr>
                  <td colspan="2">
                    <table>
                      <thead>
                        <tr>
                          <th colspan="4" align="left" valign="top">Edge Whitelist</th>
                        </tr>

                        <tr>
                          <th align="left" valign="top">Source Semantic Tag</th>

                          <th align="left" valign="top">Target Semantic Tag</th>

                          <th align="left" valign="top">Edge Semantic Tag</th>

                          <th align="right"></th>
                        </tr>
                      </thead>

                      <tbody style="font-family: monospace;">
                        <%= for ew <- syntax.edge_whitelists do %>
                          <tr>
                            <td>{ew.source_semantic_tag}</td>

                            <td>{ew.target_semantic_tag}</td>

                            <td>{ew.edge_semantic_tag}</td>

                            <td>
                              <button
                                style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                                type="button"
                                phx-click="delete_whitelist"
                                value={ew.id}
                              >
                                Delete
                              </button>
                            </td>
                          </tr>
                        <% end %>
                      </tbody>

                      <tfoot>
                        <tr>
                          <th align="left" valign="top">Source Semantic Tag</th>

                          <th align="left" valign="top">Target Semantic Tag</th>

                          <th align="left" valign="top">Edge Semantic Tag</th>

                          <th align="right"></th>
                        </tr>
                        <tr>
                          <td>
                            <input
                              form={"add_whitelist-#{syntax.id}"}
                              style="padding: 1ex"
                              name="source_semantic_tag"
                              list="semantic_tags"
                              type="text"
                            />
                          </td>

                          <td>
                            <input
                              form={"add_whitelist-#{syntax.id}"}
                              style="padding: 1ex"
                              name="target_semantic_tag"
                              list="semantic_tags"
                              type="text"
                            />
                          </td>

                          <td>
                            <input
                              form={"add_whitelist-#{syntax.id}"}
                              style="padding: 1ex"
                              name="edge_semantic_tag"
                              list="semantic_tags"
                              type="text"
                            />
                          </td>

                          <td>
                            <form id={"add_whitelist-#{syntax.id}"} phx-submit="add_whitelist">
                              <input type="hidden" name="syntax_id" value={syntax.id} />
                              <button
                                type="submit"
                                style="cursor: pointer; background: #0a0; color: #fff; padding: 1ex; border: none"
                              >
                                add
                              </button>
                            </form>
                          </td>
                        </tr>
                      </tfoot>
                    </table>
                    <br />
                    <table>
                      <thead>
                        <tr>
                          <th align="left" valign="top" colspan="8">Auto Nodes</th>
                        </tr>

                        <tr>
                          <th align="left" valign="top">Source Socket</th>

                          <th align="left" valign="top">Target Shape</th>

                          <th align="left" valign="top">Target Socket</th>

                          <th align="left" valign="top">Edge Source Tip</th>

                          <th align="left" valign="top">Edge Target Tip</th>

                          <th align="left" valign="top">Source Semantic Tag</th>

                          <th align="left" valign="top">Target Semantic Tag</th>

                          <th align="left" valign="top">Edge Semantic Tag</th>

                          <th align="left" valign="top" width="10">Target Style</th>

                          <th align="left" valign="top"></th>
                        </tr>
                      </thead>

                      <tbody style="font-family: monospace;">
                        <%= for at <- syntax.edge_auto_targets do %>
                          <tr>
                            <td>
                              <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                                {sockets[at.source_socket_id].name}
                                <% else e -> %>
                                  <%= case e do %>
                                    <% nil -> %>
                                      none
                                    <% _ -> %>
                                      loading
                                  <% end %>
                              <% end %>
                            </td>

                            <td>
                              <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols, symbol_id when not is_nil(symbol_id) <- at.target_shape_id do %>
                                {symbols[symbol_id].name}
                                <% else e -> %>
                                  <%= case e do %>
                                    <% nil -> %>
                                      none
                                    <% _ -> %>
                                      loading
                                  <% end %>
                              <% end %>
                            </td>

                            <td>
                              <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                                {sockets[at.target_socket_id].name}
                                <% else e -> %>
                                  <%= case e do %>
                                    <% nil -> %>
                                      none
                                    <% _ -> %>
                                      loading
                                  <% end %>
                              <% end %>
                            </td>

                            <td>
                              <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols, symbol_id when not is_nil(symbol_id) <- at.edge_source_tip_id do %>
                                {symbols[symbol_id].name}
                                <% else e -> %>
                                  <%= case e do %>
                                    <% nil -> %>
                                      none
                                    <% _ -> %>
                                      loading
                                  <% end %>
                              <% end %>
                            </td>

                            <td>
                              <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols, symbol_id when not is_nil(symbol_id) <- at.edge_target_tip_id do %>
                                {symbols[symbol_id].name}
                                <% else e -> %>
                                  <%= case e do %>
                                    <% nil -> %>
                                      none
                                    <% _ -> %>
                                      loading
                                  <% end %>
                              <% end %>
                            </td>

                            <td>{at.source_semantic_tag}</td>

                            <td>{at.target_semantic_tag}</td>

                            <td>{at.edge_semantic_tag}</td>
                            <td>
                              <div style="padding: 1ex; background: #666; color: #fff; max-width: 10em; white-space: wrap;word-break: break-all;">
                                {Jason.encode!(at.style)}
                              </div>
                            </td>

                            <td>
                              <button
                                style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                                type="button"
                                phx-click="delete_autonode"
                                value={at.id}
                              >
                                Delete
                              </button>
                            </td>
                          </tr>
                        <% end %>
                      </tbody>

                      <tfoot>
                        <tr>
                          <th align="left" valign="top">Source Socket</th>

                          <th align="left" valign="top">Target Shape</th>

                          <th align="left" valign="top">Target Socket</th>

                          <th align="left" valign="top">Edge Source Tip</th>

                          <th align="left" valign="top">Edge Target Tip</th>

                          <th align="left" valign="top">Source Semantic Tag</th>

                          <th align="left" valign="top">Target Semantic Tag</th>

                          <th align="left" valign="top">Edge Semantic Tag</th>

                          <th align="left" valign="top" width="10">Target Style</th>

                          <th align="left" valign="top"></th>
                        </tr>
                        <tr>
                          <td align="left" valign="top">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                              <select
                                form={"add_auto-#{syntax.id}"}
                                name="source_socket_id"
                                style="padding: 1ex; max-width: 10em"
                              >
                                <option value="">-</option>
                                <%= for {id, s} <- sockets do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left" valign="top">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select
                                form={"add_auto-#{syntax.id}"}
                                name="target_shape_id"
                                style="max-width: 10em; padding: 1ex"
                              >
                                <option value="">-</option>
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left" valign="top">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                              <select
                                form={"add_auto-#{syntax.id}"}
                                name="target_socket_id"
                                style="max-width: 10em; padding: 1ex"
                              >
                                <option value="">-</option>
                                <%= for {id, s} <- sockets do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left" valign="top">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select
                                form={"add_auto-#{syntax.id}"}
                                name="edge_source_tip_id"
                                style="max-width: 10em; padding: 1ex"
                              >
                                <option value="">-</option>
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left" valign="top">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select
                                form={"add_auto-#{syntax.id}"}
                                name="edge_target_tip_id"
                                style="max-width: 10em; padding: 1ex"
                              >
                                <option value="">-</option>
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left" valign="top">
                            <input
                              form={"add_auto-#{syntax.id}"}
                              name="source_semantic_tag"
                              style="padding: 1ex"
                              list="semantic_tags"
                            />
                          </td>

                          <td align="left" valign="top">
                            <input
                              form={"add_auto-#{syntax.id}"}
                              name="target_semantic_tag"
                              style="padding: 1ex"
                              list="semantic_tags"
                            />
                          </td>

                          <td align="left" valign="top">
                            <input
                              form={"add_auto-#{syntax.id}"}
                              name="edge_semantic_tag"
                              style="padding: 1ex"
                              list="semantic_tags"
                            />
                          </td>

                          <td align="left" valign="top">
                            <textarea form={"add_auto-#{syntax.id}"} name="style" rows="6" cols="20" />
                          </td>

                          <td align="left" valign="top">
                            <form id={"add_auto-#{syntax.id}"} phx-submit="add_autonode">
                              <input type="hidden" name="syntax_id" value={syntax.id} />

                              <button
                                type="submit"
                                style="cursor: pointer; background: #0a0; color: #fff; padding: 1ex; border: none"
                              >
                                add
                              </button>
                            </form>
                          </td>
                        </tr>
                      </tfoot>
                    </table>
                  </td>

                  <td colspan="4"></td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>

        <datalist id="semantic_tags">
          <%= for t <- semantic_tags() do %>
            <option>{t}</option>
          <% end %>
        </datalist>
      </div>
    </div>
    """
  end

  def handle_event("validate", %{"create_syntax" => %{"name" => name}}, socket) do
    {:noreply, socket |> assign(:create_form, to_form(%{"name" => name}, as: :create_syntax))}
  end

  def handle_event("save", %{"create_syntax" => params}, socket) do
    Syntax.create(params)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> assign(:create_form, to_form(%{"name" => ""}, as: :create_syntax))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("delete_syntax", %{"value" => syntax_id}, socket) do
    Syntax.delete(syntax_id)
    {:noreply, socket}
  end

  def handle_event("delete_whitelist", %{"value" => syntax_id}, socket) do
    Syntax.delete_whitelist(syntax_id)
    {:noreply, socket}
  end

  def handle_event("delete_autonode", %{"value" => syntax_id}, socket) do
    Syntax.delete_autonode(syntax_id)
    {:noreply, socket}
  end

  def handle_event("make_default", %{"value" => syntax_id}, socket) do
    Syntax.make_default(syntax_id)
    {:noreply, socket}
  end

  def handle_event(
        "add_whitelist",
        params,
        socket
      ) do
    Syntax.add_whitelist(params)

    {:noreply, socket}
  end

  def handle_event(
        "add_autonode",
        params,
        socket
      ) do
    Syntax.add_autonode(
      params
      |> Map.update("style", nil, fn
        "" ->
          nil

        s ->
          case Jason.decode(s) do
            {:ok, j} -> j
            _ -> s
          end
      end)
    )

    {:noreply, socket}
  end
end
