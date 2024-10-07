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
      :update_position,
      fn %{text: text} ->
        Text.change_position(text, new_position)
      end
    )
    |> Ecto.Multi.update_all(
      :delete_size_hint,
      fn %{text: text, update_position: %{position_x: new_x, position_y: new_y}} ->
        dx = new_x - text.position_x
        dy = new_y - text.position_y

        from(h in TextSizeHint,
          where: h.text_id == ^text.id,
          update: [inc: [position_x: ^dx, position_y: ^dy]]
        )
      end,
      []
    )
  end
end
