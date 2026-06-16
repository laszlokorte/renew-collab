defmodule RenewCollabWeb.LiveIcons do
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :live_view

  use RenewCollabCtrl.Helper,
    icons: {Views.GlobalSymbolsList, [], :symbols_changed}

  def load_param(:account, socket), do: socket.assigns.account

  def mount(_params, _session, socket) do
    socket
    |> load_data(true)
  end

  def render(assigns) do
    assigns =
      assign(assigns,
        bounds: %{
          position_x: 0,
          position_y: 0,
          width: 100,
          height: 60
        },
        padding: 50
      )

    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />
      <div style="padding: 1em">
        /
        Icons
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/images/icon-symbol.svg" /> <span>Icons</span>
        </h2>
      </div>

      <div style="padding: 1em">
        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="10">Preview</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="4">
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@icons) do %>
              <tr>
                <td colspan="6">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Icons defined yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {icon, si} <- @icons |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <svg viewBox={"#{@bounds.position_x - @padding} #{@bounds.position_y - @padding} #{@bounds.width + 2* @padding} #{@bounds.height + 2* @padding}"}>
                      <g style="color: red" stroke-width="2" fill="white" stroke="black">
                        <%= for path <- icon.paths do %>
                          <path
                            stroke-linejoin="bevel"
                            stroke={path.stroke_color}
                            fill={path.fill_color}
                            d={RenewexIconset.Builder.build_symbol_path(@bounds, path)}
                            fill-rule="evenodd"
                          />
                        <% end %>
                      </g>
                    </svg>
                  </td>

                  <td>
                    <.link style="color: #078" navigate={~p"/icon/#{icon.id}"}>{icon.name}</.link>
                  </td>

                  <td width="50"></td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
