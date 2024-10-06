defmodule RenewCollabWeb.HierarchyLayerInterfaceComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <g>
      <%= with box <- @layer.box,
            hint <-  @layer.text && @layer.text.size_hint,
            bounds <- box || hint do %>
        <%= if bounds do %>
          <%= if @selected do %>
            <%= case @socket_schema.stencil do %>
              <% :ellipse -> %>
                <ellipse
                  stroke-width="3"
                  pointer-events="none"
                  stroke-opacity="0.5"
                  fill-opacity="0.1"
                  cx={bounds.position_x + bounds.width / 2}
                  cy={bounds.position_y + bounds.height / 2}
                  fill="purple"
                  stroke="purple"
                  rx={bounds.width / 2}
                  ry={bounds.height / 2}
                />
              <% :rect -> %>
                <rect
                  stroke-width="3"
                  pointer-events="none"
                  stroke-opacity="0.5"
                  fill-opacity="0.1"
                  x={bounds.position_x}
                  y={bounds.position_y}
                  fill="purple"
                  stroke="purple"
                  width={bounds.width}
                  height={bounds.height}
                />
              <% _ -> %>
            <% end %>
          <% end %>

          <%= for s <- @socket_schema.sockets do %>
            <g
              phx-hook="RnwSocket"
              cursor="alias"
              rnw-layer-id={@layer.id}
              rnw-socket-id={s.id}
              pointer-events="all"
              fill="transparent"
              id={"socket-#{@layer.id}-#{s.id}"}
            >
              <circle
                cx={
                  RenewexIconset.Position.build_coord(
                    bounds,
                    :x,
                    false,
                    RenewexIconset.Position.unify_coord(:x, s)
                  )
                }
                cy={
                  RenewexIconset.Position.build_coord(
                    bounds,
                    :y,
                    false,
                    RenewexIconset.Position.unify_coord(:y, s)
                  )
                }
                fill="white"
                stroke="purple"
                opacity="0.4"
                r={4}
              />
              <circle
                cx={
                  RenewexIconset.Position.build_coord(
                    bounds,
                    :x,
                    false,
                    RenewexIconset.Position.unify_coord(:x, s)
                  )
                }
                cy={
                  RenewexIconset.Position.build_coord(
                    bounds,
                    :y,
                    false,
                    RenewexIconset.Position.unify_coord(:y, s)
                  )
                }
                pointer-events="all"
                rnw-layer-id={@layer.id}
                rnw-socket-id={s.id}
                r={6}
              />
            </g>
          <% end %>
        <% end %>
      <% end %>
    </g>
    """
  end
end
