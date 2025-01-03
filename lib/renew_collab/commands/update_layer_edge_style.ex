defmodule RenewCollab.Commands.UpdateLayerEdgeStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.EdgeStyle

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
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: e in assoc(l, :edge), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{edge: edge} ->
        Ecto.build_assoc(edge, :style)
        |> EdgeStyle.changeset(%{style_attr => value})
      end,
      on_conflict: {:replace, [style_attr]},
      conflict_target: [:edge_id]
    )
  end

  defp attr_key("stroke_width"), do: :stroke_width
  defp attr_key("stroke_color"), do: :stroke_color
  defp attr_key("stroke_join"), do: :stroke_join
  defp attr_key("stroke_cap"), do: :stroke_cap
  defp attr_key("stroke_dash_array"), do: :stroke_dash_array
  defp attr_key("smoothness"), do: :smoothness
  defp attr_key("source_tip_symbol_shape_id"), do: :source_tip_symbol_shape_id
  defp attr_key("target_tip_symbol_shape_id"), do: :target_tip_symbol_shape_id
end
