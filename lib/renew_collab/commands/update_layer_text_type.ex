defmodule RenewCollab.Commands.UpdateLayerTextType do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :renew_type]

  def new(%{document_id: document_id, layer_id: layer_id, renew_type: renew_type}) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      renew_type: renew_type
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, renew_type: renew_type}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(t in Text,
        join: l in assoc(t, :layer),
        where: l.id == ^layer_id
      )
    )
    |> Ecto.Multi.update(
      :text_type,
      fn %{text: text} ->
        Text.changeset(text, %{renew_type: renew_type})
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
