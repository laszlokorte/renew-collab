defmodule RenewCollab.Queries.DocumentVersions do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{
      document_id: document_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_versions, document_id}]

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:result, fn %{} ->
      from(s in Snapshot,
        where: s.document_id == ^document_id,
        left_join: l in assoc(s, :latest),
        left_join: lb in assoc(s, :label),
        select: %{
          id: s.id,
          inserted_at: s.inserted_at,
          is_latest: not is_nil(l.id),
          label: lb.description
        },
        order_by: [desc: s.inserted_at]
      )
    end)
  end
end
