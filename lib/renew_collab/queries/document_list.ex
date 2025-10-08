defmodule RenewCollab.Queries.DocumentList do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:project]

  def new(%{project: project}) do
    %__MODULE__{project: project}
  end

  def tags(%__MODULE__{project: project}), do: [{:project, project.id}, :document_collection]

  def multi(%__MODULE__{project: project}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(d in Document,
        left_join: s in assoc(d, :syntax),
        preload: [syntax: s],
        where: d.id in ^Enum.map(project.documents, fn d -> d.document_id end),
        order_by: [desc: :inserted_at, desc: :id]
      )
    )
  end
end
