defmodule RenewCollab.Symbol do
  @moduledoc """
  The Symbol context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Symbol.Path
  alias RenewCollab.Symbol.PathSegment
  alias RenewCollab.Symbol.PathStep
  alias RenewCollab.Symbol.PathStepHorizontal
  alias RenewCollab.Symbol.PathStepVertical
  alias RenewCollab.Symbol.PathStepArc

  @doc """
  Returns the list of shape.

  ## Examples

      iex> list_shape()
      [%Shape{}, ...]

  """
  def list_shapes do
    Repo.all(Shape)
    |> Repo.preload(
      paths:
        from(p in Path,
          order_by: [asc: :sort],
          preload: [
            segments:
              ^from(s in PathSegment,
                order_by: [asc: :sort],
                preload: [
                  steps:
                    ^from(s in PathStep,
                      order_by: [asc: :sort],
                      preload: [
                        :horizontal,
                        :vertical,
                        :arc
                      ]
                    )
                ]
              )
          ]
        )
    )
  end

  def ids_by_name do
    from(p in Shape, select: {p.name, p.id})
    |> Repo.all()
    |> Map.new()
  end

  def reset do
    Repo.delete_all(Shape)

    RenewCollab.Symbol.PredefinedSymbols.all()
    |> Enum.reduce(Ecto.Multi.new(), fn shape, multi ->
      multi |> Ecto.Multi.insert(Map.get(shape, "name"), %Shape{} |> Shape.changeset(shape))
    end)
    |> Repo.transaction()
  end
end
