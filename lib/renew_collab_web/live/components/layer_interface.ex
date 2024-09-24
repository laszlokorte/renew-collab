defmodule RenewCollabWeb.HierarchyLayerInterfaceComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
    <g>
      <ellipse  pointer-events="none" fill-opacity="0.3" cx={@layer.box.position_x + @layer.box.width / 2} cy={@layer.box.position_y + @layer.box.height / 2} fill="purple" stroke="purple" rx={@layer.box.width / 2} ry={@layer.box.height / 2}/>
      
      <%= for s <- @socket_schema.sockets do %>
          <circle phx-hook="RnwSocket" rnw-layer-id={@layer.id} rnw-socket-id={s.id} id={"socket-#{@layer.id}-#{s.id}"} cx={Symbol.build_coord(@layer.box, :x, false, Symbol.unify_coord(:x, s))} cy={Symbol.build_coord(@layer.box, :y, false, Symbol.unify_coord(:y, s))} fill="white" stroke="purple" r={4}/>
      <% end %>
    </g>
    """
  end
end