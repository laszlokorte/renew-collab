defmodule RenewCollabProj.Queries.CountProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:result, from(p in Project, select: count(p.id)))
  end
end
