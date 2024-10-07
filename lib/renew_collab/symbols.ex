defmodule RenewCollab.Symbols do
  def list_shapes do
    RenewCollab.Queries.ListSymbols.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def ids_by_name do
    RenewCollab.Queries.SymbolIdsByName.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end
end
