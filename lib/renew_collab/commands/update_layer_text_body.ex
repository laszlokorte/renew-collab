defmodule RenewCollab.Commands.UpdateLayerTextBody do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :new_body]

  def new(%{document_id: document_id, layer_id: layer_id, new_body: new_body}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, new_body: new_body}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, new_body: new_body}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(t in Text,
        join: l in assoc(t, :layer),
        left_join: s in assoc(t, :style),
        where: l.id == ^layer_id,
        preload: [style: s]
      )
    )
    |> Ecto.Multi.update(
      :body,
      fn %{text: text} ->
        Text.changeset(text, %{body: new_body})
      end
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
end
