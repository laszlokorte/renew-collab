defmodule RenewCollab.Commands.DuplicateDocument do
  import Ecto.Query, warn: false

  alias RenewCollab.Document.TransientDocument

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def tags(%__MODULE__{}), do: [:document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{document_id: id}) do
    RenewCollab.Queries.StrippedDocument.new(%{document_id: id})
    |> RenewCollab.Queries.StrippedDocument.multi()
    |> Ecto.Multi.run(:stripped_document, fn _, %{result: result} ->
      {:ok, result}
    end)
    |> Ecto.Multi.merge(fn %{stripped_document: %TransientDocument{} = transient_doc} ->
      RenewCollab.Commands.CreateDocument.new(%{
        doc:
          TransientDocument.update_name(
            transient_doc,
            &"#{String.trim_trailing(&1, "(Copy)")} (Copy)"
          )
      })
      |> RenewCollab.Commands.CreateDocument.multi()
    end)
  end
end
