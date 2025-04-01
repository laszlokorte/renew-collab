defmodule RenewCollabWeb.LivePrimitives do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Symbols
  alias RenewCollab.Primitives
  alias RenewCollab.Sockets

  @topic "primitives"

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    {:ok, load_data(socket)}
  end

  defp load_data(socket) do
    socket
    |> assign(:primitive_groups, Primitives.find_all())
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
        <h2 style="margin: 0;">Primitives Rules</h2>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" colspan="1"></th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Name
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Icon
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Data
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="4">
                Actions
              </th>
            </tr>
          </thead>

          <%= if Enum.empty?(@primitive_groups) do %>
            <tbody>
              <tr>
                <td colspan="7">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Primitives defined yet.
                  </div>
                </td>
              </tr>
            </tbody>
          <% else %>
            <%= for group <- @primitive_groups do %>
              <thead>
                <tr {[style: "background-color:#333;color: #fff"]}>
                  <th align="left">Icon</th>

                  <th align="left" colspan="2">
                    <strong>{group.name}</strong>
                  </th>

                  <th></th>

                  <th align="left" width="50">
                    <button type="button">Delete</button>
                  </th>
                </tr>
              </thead>

              <tbody>
                <%= if Enum.empty?(group.primitives) do %>
                  <tr>
                    <td colspan="7">
                      <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                        No Primitives defined yet.
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for {primitive, si} <- group.primitives |> Enum.with_index do %>
                    <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                      <td>
                        <svg viewBox="-8 -8 48 48" style="width: 3em">
                          {raw(primitive.icon)}
                        </svg>
                      </td>

                      <td align="left" colspan="1">
                        {primitive.name}
                      </td>

                      <td align="left" colspan="1">
                        <textarea rows="5" cols="40">{primitive.icon}</textarea>
                      </td>

                      <td align="left" colspan="1">
                        <textarea rows="5" cols="40">{Jason.encode!(primitive.data)}</textarea>
                      </td>

                      <td align="left" width="50">
                        <button type="button">Delete</button>
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            <% end %>
          <% end %>
        </table>
      </div>
    </div>
    """
  end
end
