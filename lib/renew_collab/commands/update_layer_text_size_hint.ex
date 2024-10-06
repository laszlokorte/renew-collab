defmodule RenewCollab.Commands.UpdateLayerTextSizeHint do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.TextSizeHint
  alias RenewCollab.Element.Text

  defstruct [:document_id, :layer_id, :box]

  def new(%{document_id: document_id, layer_id: layer_id, box: box}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, box: box}
  end

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, box: box}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: e in assoc(l, :text), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{text: text} ->
        Ecto.build_assoc(text, :size_hint)
        |> TextSizeHint.changeset(box)
      end,
      on_conflict: {:replace, [:position_x, :position_y, :width, :height]}
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