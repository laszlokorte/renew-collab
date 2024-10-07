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
      :result,
      from(s in Shape,
        order_by: [asc: :name],
        left_join: p in assoc(s, :paths),
        left_join: sgm in assoc(p, :segments),
        left_join: stp in assoc(sgm, :steps),
        left_join: h in assoc(stp, :horizontal),
        left_join: v in assoc(stp, :vertical),
        left_join: a in assoc(stp, :arc),
        order_by: [asc: p.sort, asc: sgm.sort, asc: stp.sort],
        preload: [
          paths:
            {p,
             [
               segments:
                 {sgm,
                  [
                    steps:
                      {stp,
                       [
                         horizontal: h,
                         vertical: v,
                         arc: a
                       ]}
                  ]}
             ]}
        ]
      )
    )
  end
end
