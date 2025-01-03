defmodule RenewCollab.Commands.UpdateLayerStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle

  defstruct [:document_id, :layer_id, :style_attr, :value]

  def new(%{document_id: document_id, layer_id: layer_id, style_attr: style_attr, value: value}) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      style_attr: attr_key(style_attr),
      value: value
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        style_attr: style_attr,
        value: value
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(:layer, from(l in Layer, where: l.id == ^layer_id))
    |> RenewCollab.Compatibility.Multi.insert(
      :style,
      fn %{layer: layer} ->
        Ecto.build_assoc(layer, :style)
        |> LayerStyle.changeset(%{style_attr => value})
      end,
      on_conflict: {:replace, [style_attr]},
      conflict_target: [:layer_id]
    )
  end

  defp attr_key("opacity"), do: :opacity
  defp attr_key("background_color"), do: :background_color
  defp attr_key("background_url"), do: :background_url
  defp attr_key("border_color"), do: :border_color
  defp attr_key("border_width"), do: :border_width
  defp attr_key("border_dash_array"), do: :border_dash_array
end
