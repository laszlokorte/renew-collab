defmodule RenewCollab.Queries.DocumentList do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:document_ids]

  def new(%{document_ids: document_ids}) do
    %__MODULE__{document_ids: document_ids}
  end

  def tags(%__MODULE__{document_ids: document_ids}),
    do: [{:document_ids, document_ids}, :document_collection]

  def multi(%__MODULE__{document_ids: :all}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(d in Document,
        left_join: s in assoc(d, :syntax),
        preload: [syntax: s],
        order_by: [desc: :inserted_at, desc: :id]
      )
    )
  end

  def multi(%__MODULE__{document_ids: document_ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(d in Document,
        left_join: s in assoc(d, :syntax),
        preload: [syntax: s],
        where: d.id in ^document_ids,
        order_by: [desc: :inserted_at, desc: :id]
      )
    )
  end
end
