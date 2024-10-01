defmodule RenewCollabWeb.HierarchyLayerInterfaceComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <g>
      <%= case @socket_schema.stencil do %>
        <% :ellipse -> %>
          <ellipse
            stroke-width="3"
            pointer-events="none"
            stroke-opacity="0.5"
            fill-opacity="0.1"
            cx={@layer.box.position_x + @layer.box.width / 2}
            cy={@layer.box.position_y + @layer.box.height / 2}
            fill="purple"
            stroke="purple"
            rx={@layer.box.width / 2}
            ry={@layer.box.height / 2}
          />
        <% :rect -> %>
          <rect
            stroke-width="3"
            pointer-events="none"
            stroke-opacity="0.5"
            fill-opacity="0.1"
            x={@layer.box.position_x}
            y={@layer.box.position_y}
            fill="purple"
            stroke="purple"
            width={@layer.box.width}
            height={@layer.box.height}
          />
        <% _ -> %>
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
                @layer.box,
                :x,
                false,
                RenewexIconset.Position.unify_coord(:x, s)
              )
            }
            cy={
              RenewexIconset.Position.build_coord(
                @layer.box,
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
                @layer.box,
                :x,
                false,
                RenewexIconset.Position.unify_coord(:x, s)
              )
            }
            cy={
              RenewexIconset.Position.build_coord(
                @layer.box,
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
    </g>
    """
  end
end
