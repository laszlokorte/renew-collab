defmodule RenewCollab.Commands.UpdateLayerEdgeStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.EdgeStyle

  defstruct [:document_id, :layer_ids, :style_attr, :value]

  def new(%{document_id: document_id, style_attr: style_attr, value: value} = attrs) do
    layer_ids = normalize_layer_ids(attrs)

    %__MODULE__{
      document_id: document_id,
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
    value = normalize_value(style_attr, value)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_styles,
      from(s in EdgeStyle,
        join: e in assoc(s, :edge),
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        update: [set: [{^style_attr, ^value}, {:updated_at, ^now}]]
      ),
      []
    )
    |> Ecto.Multi.all(
      :missing_edge_style_ids,
      from(l in Layer,
        join: e in assoc(l, :edge),
        left_join: s in assoc(e, :style),
        where: l.document_id == ^document_id and l.id in ^layer_ids and is_nil(s.id),
        select: e.id
      )
    )
    |> RenewCollab.Compatibility.Multi.insert_all(
      :insert_styles,
      EdgeStyle,
      fn %{missing_edge_style_ids: missing_edge_style_ids} ->
        Enum.map(missing_edge_style_ids, fn edge_id ->
          edge_style_row(edge_id, style_attr, value, now)
        end)
      end,
      on_conflict: {:replace, [style_attr, :updated_at]},
      conflict_target: [:edge_id]
    )
  end

  defp edge_style_row(edge_id, style_attr, value, now) do
    %{
      id: Ecto.UUID.generate(),
      stroke_width: 1.0,
      stroke_color: "black",
      stroke_opacity: 1.0,
      smoothness: :linear,
      smoothness_amount: 50.0,
      source_tip_size: 1.0,
      target_tip_size: 1.0,
      edge_id: edge_id,
      inserted_at: now,
      updated_at: now
    }
    |> Map.put(style_attr, value)
  end

  defp normalize_value(:smoothness, "autobezier"), do: :autobezier
  defp normalize_value(:smoothness, "linear"), do: :linear
  defp normalize_value(:smoothness, value), do: value
  defp normalize_value(_style_attr, value), do: value

  defp normalize_layer_ids(%{layer_ids: layer_ids}) when is_list(layer_ids) do
    layer_ids
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

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
