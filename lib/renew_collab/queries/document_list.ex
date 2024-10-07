defmodule RenewCollab.Queries.DocumentList do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(Document, order_by: [desc: :inserted_at, desc: :updated_at])
    )
  end
end
