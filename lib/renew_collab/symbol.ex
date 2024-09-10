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
    Repo.delete_all(Shape)

    %Shape{}
    |> Shape.changeset(%{
      "name" => "rectangle",
      "paths" => [
        %{
          "fill_color" => "white",
          "stroke_color" => "black",
          "sort" => 0,
          "segments" => [
            %{
              "sort" => 0,
              "relative" => false,
              "x_value" => 0,
              "y_value" => 0,
              "steps" => [
                %{
                  "sort" => 0,
                  "relative" => false,
                  "horizontal" => %{
                    "x_value" => 1,
                    "y_value" => 0
                  }
                },
                %{
                  "sort" => 1,
                  "relative" => false,
                  "horizontal" => %{
                    "x_value" => 1,
                    "y_value" => 1
                  }
                },
                %{
                  "sort" => 2,
                  "relative" => false,
                  "horizontal" => %{
                    "x_value" => 0,
                    "y_value" => 1
                  }
                },
                %{
                  "sort" => 1,
                  "relative" => false
                }
              ]
            }
          ]
        }
      ]
    })
    |> Repo.insert()
    |> dbg

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
end
