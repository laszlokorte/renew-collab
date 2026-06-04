defmodule RenewCollab.Commands.InsertLayerClipboard do
  alias RenewCollab.Commands.InsertDocument
  alias RenewCollab.Document.LayerClipboard
  alias RenewCollab.Document.TransientDocument

  defstruct [:clipboard, :document_id, :position]

  def new(%{document_id: document_id, clipboard: clipboard, position: {x, y}}) do
    %__MODULE__{
      document_id: document_id,
      clipboard: clipboard,
      position: {x, y}
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        clipboard: clipboard,
        document_id: document_id,
        position: {x, y}
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.run(:clipboard_document, fn _, _ -> LayerClipboard.decode(clipboard) end)
    |> Ecto.Multi.run(:now, fn _, _ ->
      {:ok, DateTime.utc_now() |> DateTime.truncate(:second)}
    end)
    |> Ecto.Multi.merge(fn %{
                             clipboard_document:
                               {%TransientDocument{} = transient_document, origin, root_layer_ids},
                             document_id: document_id,
                             now: now
                           } ->
      dx = x - Map.get(origin, "x", 0)
      dy = y - Map.get(origin, "y", 0)

      document_id
      |> InsertDocument.insert_into_document_multi(
        now,
        TransientDocument.shift_positions(transient_document, dx, dy)
      )
      |> Ecto.Multi.put(:inserted_layer_ids, root_layer_ids)
    end)
  end
end
