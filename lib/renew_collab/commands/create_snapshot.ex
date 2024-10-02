defmodule RenewCollab.Commands.CreateSnapshot do
  import Ecto.Query, warn: false

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.append(RenewCollab.Versioning.snapshot_multi())
  end
end
