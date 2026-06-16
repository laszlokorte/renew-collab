defmodule RenewCollab.Commands.UpdateLayerTextType do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :layer_ids, :renew_type]

  def new(%{document_id: document_id, renew_type: renew_type} = attrs) do
    layer_ids = normalize_layer_ids(attrs)

    %__MODULE__{
      document_id: document_id,
      layer_id: List.first(layer_ids),
      layer_ids: layer_ids,
      renew_type: renew_type
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{document_id: document_id, layer_ids: layer_ids, renew_type: renew_type}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(
      :texts,
      from(t in Text,
        join: l in assoc(t, :layer),
        left_join: s in assoc(t, :style),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        preload: [style: s],
        select: {l.id, t}
      )
    )
    |> Ecto.Multi.merge(fn %{texts: texts} ->
      text_ids = Enum.map(texts, fn {_layer_id, text} -> text.id end)

      texts
      |> Enum.reduce(Ecto.Multi.new(), fn {layer_id, text}, multi ->
        Ecto.Multi.update(
          multi,
          {:text_type, layer_id},
          Text.changeset(text, %{renew_type: renew_type})
        )
      end)
      |> Ecto.Multi.delete_all(
        :delete_size_hints,
        from(h in TextSizeHint, where: h.text_id in ^text_ids),
        []
      )
      |> then(fn multi ->
        Enum.reduce(texts, multi, fn {layer_id, _text}, multi ->
          Ecto.Multi.append(
            multi,
            RenewCollab.Commands.UpdateLayerTextSizeHintAuto.new(%{
              document_id: document_id,
              layer_id: layer_id
            })
            |> RenewCollab.Commands.UpdateLayerTextSizeHintAuto.multi()
          )
        end)
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
end
