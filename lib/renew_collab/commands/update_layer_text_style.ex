defmodule RenewCollab.Commands.UpdateLayerTextStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Style.TextSizeHint

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
      :texts_for_style,
      from(l in Layer,
        join: t in assoc(l, :text),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        select: {l.id, t}
      )
    )
    |> Ecto.Multi.merge(fn %{texts_for_style: texts} ->
      Enum.reduce(texts, Ecto.Multi.new(), fn {layer_id, text}, multi ->
        RenewCollab.Compatibility.Multi.insert(
          multi,
          {:style, layer_id},
          Ecto.build_assoc(text, :style)
          |> TextStyle.changeset(%{style_attr => value}),
          on_conflict: {:replace, [style_attr]},
          conflict_target: [:text_id]
        )
      end)
    end)
    |> Ecto.Multi.all(
      :texts_for_hint,
      from(l in Layer,
        join: t in assoc(l, :text),
        left_join: s in assoc(t, :style),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        preload: [style: s],
        select: {l.id, t}
      )
    )
    |> Ecto.Multi.merge(&size_hint_multi/1)
  end

  defp size_hint_multi(%{texts_for_hint: texts}) do
    text_ids = Enum.map(texts, fn {_layer_id, text} -> text.id end)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_size_hints,
      from(h in TextSizeHint, where: h.text_id in ^text_ids),
      []
    )
    |> then(fn multi ->
      Enum.reduce(texts, multi, fn {layer_id, text}, multi ->
        multi
        |> Ecto.Multi.run({:new_hint, layer_id}, fn _, _ ->
          {:ok,
           RenewCollab.TextMeasure.MeasureServer.measure(
             {font_family(text), style_as_int(text), font_size(text),
              text.body
              |> String.split("\n")
              |> Enum.filter(&(include_blank(text) or not blank?(&1)))}
           )}
        end)
        |> RenewCollab.Compatibility.Multi.insert(
          {:hint, layer_id},
          fn changes ->
            {width, height} = Map.fetch!(changes, {:new_hint, layer_id})

            Ecto.build_assoc(text, :size_hint)
            |> TextSizeHint.changeset(%{
              position_x: text.position_x,
              position_y: text.position_y,
              width: width * 1.0,
              height: height * 1.0
            })
          end,
          on_conflict: {:replace, [:position_x, :position_y, :width, :height]},
          conflict_target: [:text_id]
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

  defp include_blank(text) do
    case text.style do
      %{blank_lines: blank_lines} -> blank_lines
      _ -> false
    end
  end

  defp style_as_int(%{style: %{} = text_style}) do
    [
      if(text_style.bold, do: 1, else: 0),
      if(text_style.italic, do: 2, else: 0)
    ]
    |> Enum.reduce(0, &Bitwise.bor/2)
  end

  defp style_as_int(_), do: 0

  defp font_family(%{style: %{font_family: fm}}), do: fm
  defp font_family(_), do: "sans-serif"

  defp font_size(%{style: %{font_size: fs}}), do: fs
  defp font_size(_), do: 12

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  def attr_key("italic"), do: :italic
  def attr_key("underline"), do: :underline
  def attr_key("alignment"), do: :alignment
  def attr_key("font_size"), do: :font_size
  def attr_key("font_family"), do: :font_family
  def attr_key("bold"), do: :bold
  def attr_key("text_color"), do: :text_color
  def attr_key("opacity"), do: :opacity
  def attr_key("background_color"), do: :background_color
  def attr_key("background_opacity"), do: :background_opacity
  def attr_key("rich"), do: :rich
  def attr_key("blank_lines"), do: :blank_lines
end
