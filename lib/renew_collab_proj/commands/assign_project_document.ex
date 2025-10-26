defmodule RenewCollabProj.Commands.AssignProjectDocument do
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
  end
end
