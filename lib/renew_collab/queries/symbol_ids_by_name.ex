defmodule RenewCollab.Queries.SymbolIdsByName do
  import Ecto.Query, warn: false

  alias RenewCollab.Symbol.Shape

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def tags(%__MODULE__{}), do: [:symbols]

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :shapes,
      from(p in Shape, select: {p.name, p.id})
    )
    |> Ecto.Multi.run(:result, fn _, %{shapes: shapes} ->
      {:ok, Map.new(shapes)}
    end)
  end
end
