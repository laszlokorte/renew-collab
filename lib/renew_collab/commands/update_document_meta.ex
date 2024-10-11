defmodule RenewCollab.Commands.UpdateDocumentMeta do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:document_id, :meta]

  def new(%{document_id: document_id, meta: meta}) do
    %__MODULE__{document_id: document_id, meta: meta}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id, meta: meta}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update(:update_meta, fn %{document_id: document_id} ->
      %Document{id: document_id} |> Document.changeset_meta(meta)
    end)
  end
end
