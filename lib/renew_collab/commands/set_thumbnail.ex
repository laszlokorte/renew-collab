defmodule RenewCollab.Commands.SetThumbnail do
  import Ecto.Query, warn: false
  alias RenewCollab.Thumbnail.DocumentThumbnailLayer

  defstruct [:document_id, :layer_id]

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert(
      :insert_thumbnail,
      %DocumentThumbnailLayer{document_id: document_id, layer_id: layer_id},
      on_conflict: [set: [layer_id: layer_id]],
      conflict_target: :document_id
    )
  end
end
