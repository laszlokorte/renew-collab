defmodule RenewCollab.Queries.ListSymbols do
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
      :shape,
      from(s in Shape,
        order_by: [asc: :name]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{shape: shape} ->
      {:ok,
       repo.preload(
         shape,
         [
           {:paths,
            [
              {
                :segments,
                [
                  {:steps,
                   [
                     :horizontal,
                     :vertical,
                     :arc
                   ]}
                ]
              }
            ]}
         ]
       )}
    end)
  end
end
