defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Simulation.SimulationLink

  def count_documents do
    :deprecated
  end

  def count_snapshots do
    from(s in Snapshot, select: count()) |> Repo.one()
  end

  def get_document(id), do: Repo.get(Document, id)

  def get_document_with_elements(document_id) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.Queries.DocumentWithElements.multi()
    |> RenewCollab.Repo.transact()
    |> then(fn {:ok, %{result: result}} -> result end)
  end

  def list_simulation_links(document_id) do
    Repo.all(
      from(l in SimulationLink,
        where: l.document_id == ^document_id,
        order_by: [desc: l.inserted_at]
      )
    )
    |> RenewCollabSim.Repo.preload([:simulation])
  end
end
