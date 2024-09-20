defmodule RenewCollabWeb.HierarchyStyleField do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div style="display: flex; align-items: stretch; gap: 0.5ex">

      <%= case options(@element, @attr, @type) do %>

      <% [true, false] -> %>
      <input {attrs(@element, @attr, @type)} checked={@value} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr} style="padding: 0.5ex;" type={@type} />

      <% options when is_list(options) -> %>
        <select {attrs(@element, @attr, @type)} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr} style="padding: 0.5ex; ">
          <%= for o <- options do %>
            <option selected={@value == o} value={o}><%= o %></option>
          <% end %>
        </select>
      <% _ -> %>
        <input {attrs(@element, @attr, @type)} value={@value} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr} style="padding: 0.5ex; " type={@type} />
      <% end%>
      <%= unless is_nil(default_value(@element, @attr, @type)) do %>
      <button style="text-align: center; align-self: center; cursor: pointer; border: none; background: #333; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 100%; font-weight: bold;" value={default_value(@element, @attr, @type)} phx-hook="RenewStyleAttribute" id={"layer-style-#{@layer.id}-#{@element}-#{@attr}-reset"}  rnw-layer-id={"#{@layer.id}"} rnw-element={@element} rnw-style={@attr}>&times;</button>
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

  def options(el, :alignment, :text),
    do: [
      :left,
      :center,
      :right
    ]

  def options(el, :stroke_join, :text),
    do: [
      :arcs,
      :bevel,
      :miter,
      :"miter-clip",
      :round
    ]

  def options(el, :stroke_cap, :text),
    do: [
      :round,
      :butt,
      :square
    ]

  def options(el, :smoothness, :text),
    do: [
      :linear,
      :autobezier
    ]

  def options(el, _, :checkbox),
    do: [
      true,
      false
    ]

  def options(el, attr, type), do: nil

  def attrs(el, :opacity, :number),
    do: [step: 0.01, min: 0, max: 1, style: "width: 3em; padding: 0.5ex"]

  def attrs(el, :border_width, :number), do: [step: 1, min: 0]
  def attrs(el, :font_size, :number), do: [step: 1, min: 0]
  def attrs(el, attr, type), do: []
end
