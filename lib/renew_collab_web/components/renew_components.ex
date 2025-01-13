defmodule RenewCollabWeb.RenewComponents do
  use Phoenix.Component
  use RenewCollabWeb, :verified_routes

  defp app_titel() do
    Application.get_env(:renew_collab, :app_titel)
  end

  attr :blank, :boolean, default: false
  attr :logout, :boolean, default: false

  def app_header(assigns) do
    ~H"""
    <header style="background: #333; color: #fff; padding: 1em; display: flex; justify-content: space-between; font-family: monospace;">
      <.link style="color: white; align-self: center; text-decoration: none" navigate={~p"/"}>
        <h1 style="margin: 0; font-size: 1.3em; display: flex; align-items: center; gap: 1ex">
          <img src="/favicon.svg" style="width: 1.5em; height: 1.5em" /> {app_titel()}
        </h1>
      </.link>
      <%= if not @blank do %>
        <div style="display: flex; gap: 2em; align-items: stretch;">
          <.link style="color: white; align-self: center;" navigate={~p"/documents"}>Documents</.link>
          <.link style="color: white; align-self: center;" navigate={~p"/shadow_nets"}>
            Simulations
          </.link>
          <.link style="color: white; align-self: center;" navigate={~p"/"}>Dashboard</.link>
        </div>
      <% end %>

      <%= if @logout do %>
        <.link style="color: white; align-self: center;" href={~p"/logout"} method="delete">
          Log out
        </.link>
      <% end %>
    </header>
    """
  end

  attr :document, :map, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  def layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood == nil and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>
          {render_slot(@item, child_layer)}
        </:item>
      </.child_layers>
    <% end %>
    """
  end

  attr :document, :map, required: true
  attr :parent_id, :string, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  defp child_layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood, layer.direct_parent_hood.ancestor_id == @parent_id and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>
          {render_slot(@item, child_layer)}
        </:item>
      </.child_layers>
    <% end %>
    """
  end

  defp of_type(nil, _), do: true
  defp of_type(:box, layer), do: not is_nil(layer.box) or is_group(layer)
  defp of_type(:text, layer), do: not is_nil(layer.text) or is_group(layer)
  defp of_type(:edge, layer), do: not is_nil(layer.edge) or is_group(layer)

  defp is_group(layer), do: is_nil(layer.box) and is_nil(layer.text) and is_nil(layer.edge)
end
