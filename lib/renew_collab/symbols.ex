defmodule RenewCollab.Symbols do
  def list_shapes do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def ids_by_name do
    RenewCollab.Queries.SymbolIdsByName.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def find_symbol(id) do
    import Ecto.Query

    RenewCollab.Repo.one(
      from(s in RenewCollab.Symbol.Shape,
        order_by: [asc: :name],
        left_join: p in assoc(s, :paths),
        left_join: sgm in assoc(p, :segments),
        left_join: stp in assoc(sgm, :steps),
        left_join: h in assoc(stp, :horizontal),
        left_join: v in assoc(stp, :vertical),
        left_join: a in assoc(stp, :arc),
        order_by: [asc: p.sort, asc: sgm.sort, asc: stp.sort],
        where: s.id == ^id,
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
