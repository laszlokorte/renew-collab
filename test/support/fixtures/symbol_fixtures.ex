defmodule RenewCollab.SymbolFixtures do
  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Repo

  def shape_fixture() do
    RenewexIconset.Predefined.all()
    |> Enum.reduce(Ecto.Multi.new(), fn shape, m ->
      m
      |> Ecto.Multi.insert(
        {:insert_shape, Map.get(shape, :name)},
        %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape)
      )
    end)
    |> Repo.transaction()
  end
end
