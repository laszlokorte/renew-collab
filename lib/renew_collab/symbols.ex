defmodule RenewCollab.Symbols do
  @fa_start_shape %{
    id: "F0B14E19-1228-4E75-8E45-5F739FA4F801",
    name: "ellipse-arrow-inward-north-west",
    paths: []
  }
  @fa_start_end_shape %{
    id: "508A3F11-09DF-4D3D-9C7E-48D6A4F97127",
    name: "ellipse-double-in-arrow-inward-north-west",
    paths: []
  }

  def predefined_shapes do
    RenewexIconset.Predefined.all() ++ [@fa_start_shape, @fa_start_end_shape]
  end

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
