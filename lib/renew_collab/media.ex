defmodule RenewCollab.Media do
  import Ecto.Query
  alias RenewCollab.Repo
  alias RenewCollab.Media.Svg

  def get_svg(id), do: Repo.get(Svg, id)

  def count(), do: Repo.one(from s in Svg, select: count())

  def create_svg(attrs) do
    %Svg{}
    |> Svg.changeset(attrs)
    |> Repo.insert()
  end
end
