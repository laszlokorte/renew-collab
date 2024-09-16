defmodule RenewCollabWeb.HierarchyLayerComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
    <g style={"display: #{if(@layer.hidden, do: "none", else: "initial")}"} phx-click="select_layer" phx-value-id={@layer.id}>
      <g>
        <%= for child <- @document.layers, child.direct_parent, child.direct_parent.ancestor_id == @layer.id do %> 
          <.live_component id={child.id} module={RenewCollabWeb.HierarchyLayerComponent} document={@document} layer={child} selected={@selection == child.id} symbols={@symbols} />
        <% end %>
      </g>
      
      <%= if @layer.text do %>
        <.live_component id={"text-#{@layer.id}"} module={RenewCollabWeb.HierarchyLayerTextComponent} layer={@layer}  selected={@selected} symbols={@symbols} />
      <% end %>
      <%= if @layer.box do %>          
        <.live_component  id={"box-#{@layer.id}"} module={RenewCollabWeb.HierarchyLayerBoxComponent} layer={@layer}  selected={@selected} symbols={@symbols} />
      <% end %>
      <%= if @layer.edge do %>
          <.live_component  id={"edge-#{@layer.id}"} module={RenewCollabWeb.HierarchyLayerEdgeComponent} layer={@layer}  selected={@selected} symbols={@symbols} />
      <% end %>

    </g>
    """
  end
end
