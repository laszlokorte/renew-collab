defmodule RenewCollab.Symbols do
  def list_shapes do
    RenewCollab.Queries.SocketsById.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> case do
      {:ok, result} -> result
    end
  end

  def ids_by_name do
    RenewCollab.Queries.SymbolIdsByName.new()
    |> RenewCollab.DocumentFetcher.fetch()
    |> case do
      {:ok, result} -> result
    end
  end

  def find_symbol(id) do
    import Ecto.Query

    RenewCollab.Repo.one(
      from(s in RenewCollab.Symbol.Shape,
        order_by: [asc: :name],
        where: s.id == ^id
      )
    )
    |> RenewCollab.Repo.preload([
      {:paths,
       [
         {:segments,
          [
            {
              :steps,
              [
                :horizontal,
                :vertical,
                :arc
              ]
            }
          ]}
       ]}
    ])
  end
end
