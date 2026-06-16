defmodule RenewCollab.Symbols do
  alias RenewCollab.Symbol.Shape

  def predefined_shapes do
    RenewexIconset.Predefined.all()
  end

  def ensure_custom_shapes_multi(multi \\ Ecto.Multi.new()) do
    Enum.reduce(predefined_shapes(), multi, fn shape, multi ->
      Ecto.Multi.insert_or_update(
        multi,
        {:insert_shape, Map.get(shape, :name)},
        %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape),
        on_conflict: :nothing
      )
    end)
  end

  def shape_name_by_id(id) do
    predefined_shapes()
    |> Enum.find_value(fn
      %{id: ^id, name: name} -> name
      _shape -> nil
    end)
  end

  def list_shapes do
    RenewCollab.Queries.ListSymbols.new()
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
    |> case do
      nil ->
        nil

      shape ->
        RenewCollab.Repo.preload(shape, [
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
end
