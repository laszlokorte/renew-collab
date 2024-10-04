defmodule RenewCollab.Commands.UpdateLayerTextPosition do
  import Ecto.Query, warn: false

  alias RenewCollab.Style.TextSizeHint
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Text

  defstruct [:document_id, :layer_id, :new_position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{text: text} ->
        Text.change_position(text, new_position)
      end
    )
    |> Ecto.Multi.delete_all(
      :delete_size_hint,
      fn %{text: text} ->
        from(h in TextSizeHint, where: h.text_id == ^text.id)
      end,
      []
    )
  end
end
