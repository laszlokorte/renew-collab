defmodule RenewCollab.Commands.DeleteDocument do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [
      {:document_content, document_id},
      {:document_versions, document_id},
      :document_collection
    ]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.delete(:document, fn %{document_id: id} ->
      %Document{id: id}
    end)
  end
end
