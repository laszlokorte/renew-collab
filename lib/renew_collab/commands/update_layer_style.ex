defmodule RenewCollab.Commands.UpdateLayerStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle

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
      from(s in LayerStyle,
        join: l in Layer,
        on: s.layer_id == l.id,
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        update: [set: [{^style_attr, ^value}, {:updated_at, ^now}]]
      ),
      []
    )
    |> Ecto.Multi.all(
      :missing_layer_style_ids,
      from(l in Layer,
        left_join: s in assoc(l, :style),
        where: l.document_id == ^document_id and l.id in ^layer_ids and is_nil(s.id),
        select: l.id
      )
    )
    |> RenewCollab.Compatibility.Multi.insert_all(
      :insert_styles,
      LayerStyle,
      fn %{missing_layer_style_ids: missing_layer_style_ids} ->
        Enum.map(missing_layer_style_ids, fn layer_id ->
          layer_style_row(layer_id, style_attr, value, now)
        end)
      end,
      on_conflict: {:replace, [style_attr, :updated_at]},
      conflict_target: [:layer_id]
    )
  end

  defp layer_style_row(layer_id, style_attr, value, now) do
    %{
      id: Ecto.UUID.generate(),
      opacity: 1.0,
      background_opacity: 1.0,
      border_opacity: 1.0,
      layer_id: layer_id,
      inserted_at: now,
      updated_at: now
    }
    |> Map.put(style_attr, value)
  end

  defp normalize_value(_style_attr, value), do: value

  defp normalize_layer_ids(%{layer_ids: layer_ids}) when is_list(layer_ids) do
    layer_ids
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp normalize_layer_ids(_), do: []

  defp attr_key("opacity"), do: :opacity
  defp attr_key("background_color"), do: :background_color
  defp attr_key("background_opacity"), do: :background_opacity
  defp attr_key("background_url"), do: :background_url
  defp attr_key("border_color"), do: :border_color
  defp attr_key("border_opacity"), do: :border_opacity
  defp attr_key("border_width"), do: :border_width
  defp attr_key("border_dash_array"), do: :border_dash_array
  defp attr_key("target_location"), do: :target_location
end
