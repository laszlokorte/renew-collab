defmodule RenewCollab.Commands.UpdateLayerTextStyle do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Style.TextSizeHint

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
      :text,
      from(l in Layer, join: e in assoc(l, :text), where: l.id == ^layer_id, select: e)
    )
    |> RenewCollab.Compatibility.Multi.insert(
      :style,
      fn %{text: text} ->
        Ecto.build_assoc(text, :style)
        |> TextStyle.changeset(%{style_attr => value})
      end,
      on_conflict: {:replace, [style_attr]},
      conflict_target: [:text_id]
    )
    |> Ecto.Multi.delete_all(
      :delete_size_hint,
      fn %{text: text} ->
        from(h in TextSizeHint, where: h.text_id == ^text.id)
      end,
      []
    )
    |> Ecto.Multi.append(
      RenewCollab.Commands.UpdateLayerTextSizeHintAuto.new(%{
        document_id: document_id,
        layer_id: layer_id
      })
      |> RenewCollab.Commands.UpdateLayerTextSizeHintAuto.multi()
    )
  end

  def attr_key("italic"), do: :italic
  def attr_key("underline"), do: :underline
  def attr_key("alignment"), do: :alignment
  def attr_key("font_size"), do: :font_size
  def attr_key("font_family"), do: :font_family
  def attr_key("bold"), do: :bold
  def attr_key("text_color"), do: :text_color
  def attr_key("rich"), do: :rich
  def attr_key("blank_lines"), do: :blank_lines
end
