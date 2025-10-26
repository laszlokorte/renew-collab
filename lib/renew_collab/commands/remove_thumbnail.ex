defmodule RenewCollab.Commands.RemoveThumbnail do
  import Ecto.Query, warn: false
  alias RenewCollab.Thumbnail.DocumentThumbnailLayer

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{
      document_id: document_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id
      }) do
    Ecto.Multi.new()
    |> Ecto.delete_all(
      :deleted,
      from(d in DocumentThumbnailLayer, where: d.document_id == ^document_id),
      []
    )
  end
end
