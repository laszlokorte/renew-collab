defmodule RenewCollabWeb.HierarchyStyleField do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div style="display: flex; align-items: stretch; gap: 0.5ex">
      <%= case options(@element, @attr, @type) do %>
        <% :symbols -> %>
          <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
            <select
              {attrs(@element, @attr, @type)}
              phx-hook="RenewStyleAttribute"
              id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}
              rnw-layer-id={"#{@layer.id}"}
              rnw-element={@element}
              rnw-style={@attr}
              style="padding: 0.5ex; "
            >
              <option value="">None</option>

              <%= for {sid, s} <- symbols, s.name |> String.starts_with?("arrow") do %>
                <option selected={@value == sid} value={sid}>{s.name}</option>
              <% end %>
            </select>
            <% else _ -> %>
              Loading...
          <% end %>
        <% [true, false] -> %>
          <input
            {attrs(@element, @attr, @type)}
            checked={@value}
            phx-hook="RenewStyleAttribute"
            id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-element={@element}
            rnw-style={@attr}
            style="padding: 0.5ex;"
            type={@type}
          />
        <% options when is_list(options) -> %>
          <select
            {attrs(@element, @attr, @type)}
            phx-hook="RenewStyleAttribute"
            id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-element={@element}
            rnw-style={@attr}
            style="padding: 0.5ex; "
          >
            <%= for o <- options do %>
              <option selected={@value == o} value={o}>{o}</option>
            <% end %>
          </select>
        <% _ -> %>
          <input
            {attrs(@element, @attr, @type)}
            value={@value}
            phx-hook="RenewStyleAttribute"
            id={"layer-style-#{@layer.id}-#{@element}-#{@attr}"}
            rnw-layer-id={"#{@layer.id}"}
            rnw-element={@element}
            rnw-style={@attr}
            style="padding: 0.5ex; "
            type={@type}
          />
      <% end %>

      <%= unless is_nil(default_value(@element, @attr, @type)) do %>
        <button
          style="text-align: center; align-self: center; cursor: pointer; border: none; background: #333; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 100%; font-weight: bold;"
          value={default_value(@element, @attr, @type)}
          phx-hook="RenewStyleAttribute"
          id={"layer-style-#{@layer.id}-#{@element}-#{@attr}-reset"}
          rnw-layer-id={"#{@layer.id}"}
          rnw-element={@element}
          rnw-style={@attr}
        >
          &times;
        </button>
      <% end %>
    </div>
    """
  end

  def default_value(_el, _attr, :color), do: "transparent"
  def default_value(_el, :opacity, :number), do: 1.0
  def default_value(_el, :border_width, :number), do: 0
  def default_value(_el, :font_size, :number), do: 12
  def default_value(_el, :alignment, :text), do: "left"
  def default_value(_el, :font_family, :text), do: "sans-serif"
  def default_value(_el, :border_dash_array, :text), do: ""
  def default_value(_el, _attr, _type), do: nil

  def options(_el, :alignment, :text),
    do: [
      :left,
      :center,
      :right
    ]

  def options(_el, :stroke_join, :text),
    do: [
      :arcs,
      :bevel,
      :miter,
      :"miter-clip",
      :round
    ]

  def options(_el, :stroke_cap, :text),
    do: [
      :square,
      :round,
      :butt
    ]

  def options(_el, :smoothness, :text),
    do: [
      :linear,
      :autobezier
    ]

  def options(_el, _, :checkbox),
    do: [
      true,
      false
    ]

  def options(_el, _attr, :symbol), do: :symbols

  def options(_el, _attr, _type), do: nil

  def attrs(_el, :opacity, :number),
    do: [step: 0.01, min: 0, max: 1, style: "width: 3em; padding: 0.5ex"]

  def attrs(_el, :source_tip_size, :number),
    do: [step: 0.01, min: 0, max: 5, style: "width: 7em; padding: 0.5ex"]

  def attrs(_el, :target_tip_size, :number),
    do: [step: 0.01, min: 0, max: 5, style: "width: 7em; padding: 0.5ex"]

  def attrs(_el, :border_width, :number), do: [step: 1, min: 0]
  def attrs(_el, :font_size, :number), do: [step: 1, min: 0]
  def attrs(_el, _attr, _type), do: []
end
