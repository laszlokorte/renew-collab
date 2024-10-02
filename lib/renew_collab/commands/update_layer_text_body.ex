defmodule RenewCollab.Commands.UpdateLayerTextBody do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Text

  defstruct [:document_id, :layer_id, :new_body]

  def new(%{document_id: document_id, layer_id: layer_id, new_body: new_body}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, new_body: new_body}
  end

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, new_body: new_body}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :body,
      fn %{text: text} ->
        Text.changeset(text, %{body: new_body})
      end
    )
  end
end
