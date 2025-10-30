defmodule RenewCollabSim.Queries.CountSimulations do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:result, from(sns in Simulation, select: count(sns.id)))
  end
end
