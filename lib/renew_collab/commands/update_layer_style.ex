defmodule RenewCollab.Commands.UpdateLayerStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle

  defstruct [:document_id, :layer_id, :layer_ids, :style_attr, :value]

  def new(%{document_id: document_id, style_attr: style_attr, value: value} = attrs) do
    layer_ids = normalize_layer_ids(attrs)

    %__MODULE__{
      document_id: document_id,
      layer_id: List.first(layer_ids),
      layer_ids: layer_ids,
      style_attr: attr_key(style_attr),
      value: value
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        style_attr: style_attr,
        value: value
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(
      :layers,
      from(l in Layer, where: l.document_id == ^document_id and l.id in ^layer_ids)
    )
    |> Ecto.Multi.merge(fn %{layers: layers} ->
      Enum.reduce(layers, Ecto.Multi.new(), fn layer, multi ->
        RenewCollab.Compatibility.Multi.insert(
          multi,
          {:style, layer.id},
          Ecto.build_assoc(layer, :style)
          |> LayerStyle.changeset(%{style_attr => value}),
          on_conflict: {:replace, [style_attr]},
          conflict_target: [:layer_id]
        )
      end)
    end)
  end

  defp normalize_layer_ids(%{layer_ids: layer_ids}) when is_list(layer_ids) do
    layer_ids
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp normalize_layer_ids(%{layer_id: layer_id}) when is_binary(layer_id), do: [layer_id]
  defp normalize_layer_ids(_), do: []

  defp attr_key("opacity"), do: :opacity
  defp attr_key("background_color"), do: :background_color
  defp attr_key("background_opacity"), do: :background_opacity
  defp attr_key("background_url"), do: :background_url
  defp attr_key("border_color"), do: :border_color
  defp attr_key("border_opacity"), do: :border_opacity
  defp attr_key("border_width"), do: :border_width
  defp attr_key("border_dash_array"), do: :border_dash_array
end
