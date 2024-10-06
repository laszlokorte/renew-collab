defmodule RenewCollabWeb.HierarchyStyleList do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <dl style="display: grid; grid-template-columns: max-content 1fr; gap: 0.5em">
      <%= for {attr, type} <- @attrs do %>
        <dt>
          <label for={"layer-style-#{@layer.id}-#{@element_type}-#{attr}"}>
            <%= attr
            |> Atom.to_string()
            |> String.split("_")
            |> Enum.map(&String.capitalize/1)
            |> Enum.join(" ") %>
          </label>
          <br />
          <small style="display: block; max-width: 10em; overflow: hidden; text-overflow: ellipsis; font-family: monospace">
            <%= style_or_default(@element, attr) %>
          </small>
        </dt>

        <dd>
          <.live_component
            symbols={@symbols}
            value={style_or_default(@element, attr)}
            element={@element_type}
            id={"layer-style-#{@layer.id}-#{attr}"}
            module={RenewCollabWeb.HierarchyStyleField}
            layer={@layer}
            attr={attr}
            type={type}
          />
        </dd>
      <% end %>
    </dl>
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

  defp default_style(:background_color), do: "transparent"
  defp default_style(:border_width), do: 1
  defp default_style(:opacity), do: 1.0
  defp default_style(:font_size), do: 12
  defp default_style(:alignment), do: "left"
  defp default_style(:font_family), do: "sans-serif"
  defp default_style(:border_dash_array), do: ""
  defp default_style(_style_key), do: nil
end
