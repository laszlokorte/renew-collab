defmodule RenewCollabProj.Commands.CreateProject do
  alias RenewCollabProj.Entities.Project

  defstruct [:name]

  def new(%{name: name}) do
    %__MODULE__{name: name}
  end

  def multi(%__MODULE__{name: name}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:project, %Project{
      name: name
    })
  end
end
