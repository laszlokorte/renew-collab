defmodule RenewCollab.Symbols do
  alias RenewCollab.Symbol.Shape

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

  @custom_shapes [@fa_start_shape, @fa_start_end_shape]

  def predefined_shapes do
    RenewexIconset.Predefined.all() ++ custom_shapes()
  end

  def custom_shapes, do: @custom_shapes

  def custom_shape_ids_by_name do
    Map.new(custom_shapes(), &{&1.name, &1.id})
  end

  def custom_shape_name_by_id(id) do
    custom_shapes()
    |> Enum.find_value(fn
      %{id: ^id, name: name} -> name
      _shape -> nil
    end)
  end

  def ensure_custom_shapes_multi(multi \\ Ecto.Multi.new()) do
    Enum.reduce(custom_shapes(), multi, fn shape, multi ->
      Ecto.Multi.insert_or_update(
        multi,
        {:insert_custom_shape, Map.get(shape, :name)},
        %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape),
        on_conflict: :nothing
      )
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
      {:ok, result} -> Map.merge(result, custom_shape_ids_by_name())
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
        Enum.find(custom_shapes(), &(&1.id == id))

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
