defmodule RenewCollabWeb.HierarchyLayerComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
    <g style={"display: #{if(@layer.hidden, do: "none", else: "initial")}"} phx-click="select_layer" phx-value-id={@layer.id}>
      <g opacity={style_or_default(@layer, :opacity)}>
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
