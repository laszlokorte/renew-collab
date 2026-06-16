defmodule RenewCollab.Commands.UpdateLayerEdgeStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.EdgeStyle

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
      :edges,
      from(l in Layer,
        join: e in assoc(l, :edge),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        select: {l.id, e}
      )
    )
    |> Ecto.Multi.merge(fn %{edges: edges} ->
      Enum.reduce(edges, Ecto.Multi.new(), fn {layer_id, edge}, multi ->
        RenewCollab.Compatibility.Multi.insert(
          multi,
          {:style, layer_id},
          Ecto.build_assoc(edge, :style)
          |> EdgeStyle.changeset(%{style_attr => value}),
          on_conflict: {:replace, [style_attr]},
          conflict_target: [:edge_id]
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

  defp attr_key("stroke_width"), do: :stroke_width
  defp attr_key("stroke_color"), do: :stroke_color
  defp attr_key("stroke_opacity"), do: :stroke_opacity
  defp attr_key("stroke_join"), do: :stroke_join
  defp attr_key("stroke_cap"), do: :stroke_cap
  defp attr_key("stroke_dash_array"), do: :stroke_dash_array
  defp attr_key("smoothness"), do: :smoothness
  defp attr_key("smoothness_amount"), do: :smoothness_amount
  defp attr_key("source_tip_symbol_shape_id"), do: :source_tip_symbol_shape_id
  defp attr_key("target_tip_symbol_shape_id"), do: :target_tip_symbol_shape_id
  defp attr_key("source_tip_size"), do: :source_tip_size
  defp attr_key("target_tip_size"), do: :target_tip_size
end
