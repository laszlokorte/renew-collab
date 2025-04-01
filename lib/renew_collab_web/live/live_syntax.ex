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

  defp load_data(socket) do
    socket
    |> assign(:syntax_types, Syntax.find_all())
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

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000" colspan="2">
                Name
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="4">
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
              <%= for {syntax, si} <- @syntax_types |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td colspan="2">
                    {syntax.name}

                    <%= if syntax.default do %>
                      (default)
                    <% end %>
                  </td>

                  <td width="50">
                    <button type="button">Delete</button>
                  </td>
                </tr>

                <tr>
                  <td colspan="2">
                    <table>
                      <thead>
                        <tr>
                          <th colspan="4" align="left">Edge Whitelist</th>
                        </tr>

                        <tr>
                          <th align="left">Source Semantic Tag</th>

                          <th align="left">Target Semantic Tag</th>

                          <th align="left">Edge Semantic Tag</th>

                          <th align="right"></th>
                        </tr>
                      </thead>

                      <tbody>
                        <%= for ew <- syntax.edge_whitelists do %>
                          <tr>
                            <td>{ew.source_semantic_tag}</td>

                            <td>{ew.target_semantic_tag}</td>

                            <td>{ew.edge_semantic_tag}</td>

                            <td><button type="button">delete</button></td>
                          </tr>
                        <% end %>
                      </tbody>

                      <tfoot>
                        <tr>
                          <td><input list="semantic_tags" type="text" /></td>

                          <td><input list="semantic_tags" type="text" /></td>

                          <td><input list="semantic_tags" type="text" /></td>

                          <td><button type="button">add</button></td>
                        </tr>
                      </tfoot>
                    </table>
                    <br />
                    <table>
                      <thead>
                        <tr>
                          <th align="left" colspan="8">Auto Nodes</th>
                        </tr>

                        <tr>
                          <th align="left">Source Socket</th>

                          <th align="left">Target Shape</th>

                          <th align="left">Target Socket</th>

                          <th align="left">Edge Source Tip</th>

                          <th align="left">Edge Target Tip</th>

                          <th align="left">Source Semantic Tag</th>

                          <th align="left">Target Semantic Tag</th>

                          <th align="left">Edge Semantic Tag</th>

                          <th align="left"></th>
                        </tr>
                      </thead>

                      <tbody>
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

                            <td><button>delete</button></td>
                          </tr>
                        <% end %>
                      </tbody>

                      <tfoot>
                        <tr>
                          <td align="left">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                              <select style="max-width: 10em">
                                <%= for {id, s} <- sockets do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select style="max-width: 10em">
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: sockets} <- @sockets do %>
                              <select style="max-width: 10em">
                                <%= for {id, s} <- sockets do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select style="max-width: 10em">
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left">
                            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
                              <select style="max-width: 10em">
                                <%= for {id, s} <- symbols do %>
                                  <option value={id}>{s.name}</option>
                                <% end %>
                              </select>
                              <% else _e -> %>
                                loading
                            <% end %>
                          </td>

                          <td align="left"><input list="semantic_tags" /></td>

                          <td align="left"><input list="semantic_tags" /></td>

                          <td align="left"><input list="semantic_tags" /></td>

                          <td align="left"><button>add</button></td>
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
end
