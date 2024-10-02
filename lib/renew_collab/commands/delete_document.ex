defmodule RenewCollab.Commands.DeleteDocument do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.delete(:document, fn %{document_id: id} ->
      %Document{id: id}
    end)
  end
end
