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

  def list_simulation_document_ids(simulation_ids) do
    ids =
      simulation_ids
      |> List.wrap()
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    Repo.all(
      from(l in SimulationLink,
        where: l.simulation_id in ^ids,
        select: {l.simulation_id, l.document_id}
      )
    )
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {simulation_id, document_ids} ->
      {simulation_id, Enum.uniq(document_ids)}
    end)
  end
end
