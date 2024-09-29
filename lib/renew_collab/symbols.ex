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
    Repo.all(Shape, order_by: [asc: :name])
    |> Repo.preload(
      paths: [
        segments: [
          steps: [
            :horizontal,
            :vertical,
            :arc
          ]
        ]
      ]
    )
  end

  def ids_by_name do
    from(p in Shape, select: {p.name, p.id})
    |> Repo.all()
    |> Map.new()
  end
end
