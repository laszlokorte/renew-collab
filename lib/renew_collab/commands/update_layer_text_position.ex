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

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

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
      :update_size_hint,
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
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{text: text} ->
        from(own_text in Text,
          join: own_layer in assoc(own_text, :layer),
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          where: own_text.id == ^text.id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
