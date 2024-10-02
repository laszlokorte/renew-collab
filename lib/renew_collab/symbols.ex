defmodule RenewCollab.Symbols do
  @moduledoc """
  The Symbol context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Symbol.Shape

  @doc """
  Returns the list of shape.

  ## Examples

      iex> list_shape()
      [%Shape{}, ...]

  """
  def list_shapes do
    RenewCollab.SimpleCache.cache(
      :symbol_list_shapes,
      fn ->
        Repo.all(
          from(s in Shape,
            order_by: [asc: :name],
            left_join: p in assoc(s, :paths),
            left_join: sgm in assoc(p, :segments),
            left_join: stp in assoc(sgm, :steps),
            left_join: h in assoc(stp, :horizontal),
            left_join: v in assoc(stp, :vertical),
            left_join: a in assoc(stp, :arc),
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
      end,
      :infinity
    )
  end

  def ids_by_name do
    RenewCollab.SimpleCache.cache(
      :symbol_ids_by_name,
      fn ->
        from(p in Shape, select: {p.name, p.id})
        |> Repo.all()
        |> Map.new()
      end,
      :infinity
    )
  end
end
