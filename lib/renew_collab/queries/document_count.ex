defmodule RenewCollab.Queries.DocumentCount do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(d in Document, select: count(d.id))
    )
  end
end
