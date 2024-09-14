defmodule RenewCollabWeb.HierarchyStyleField do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        
        <label>
      <%= @attr %>
      <input {if(@type == :checkbox, do: [checked: @value], else: [value: @value])} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr} style="padding: 0; " type={@type} />
      </label>
      <%= unless is_nil(default_value(@element, @attr, @type)) do %>
      <button value={default_value(@element, @attr, @type)} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}-reset"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr}>X</button>
      <% end %>
      </div>
    """
  end

  def default_value(el, attr, :color), do: "transparent"
  def default_value(el, :opacity, :number), do: 1.0
  def default_value(el, :border_width, :number), do: 0
  def default_value(el, :font_size, :number), do: 12
  def default_value(el, :alignment, :text), do: "left"
  def default_value(el, :font_family, :text), do: "sans-serif"
  def default_value(el, :border_dash_array, :text), do: ""
  def default_value(el, attr, type), do: nil
end
