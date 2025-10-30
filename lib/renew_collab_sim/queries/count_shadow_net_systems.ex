defmodule RenewCollabSim.Queries.CountShadowNetSystems do
  alias RenewCollabSim.Entities.ShadowNetSystem
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:result, from(sns in ShadowNetSystem, select: count(sns.id)))
  end
end
