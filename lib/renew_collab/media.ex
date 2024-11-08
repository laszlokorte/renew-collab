defmodule RenewCollab.Media do
  alias RenewCollab.Repo
  alias RenewCollab.Media.Svg

  def get_svg(id), do: Repo.get(Svg, id)

  def create_svg(attrs) do
    %Svg{}
    |> Svg.changeset(attrs)
    |> Repo.insert()
  end
end
