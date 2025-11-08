defmodule RenewCollabSim.Queries.SimulationNetInstanceSimple do
  alias RenewCollabSim.Entities.SimulationNetInstance
  import Ecto.Query

  defstruct [:net_instance_id]

  def new(%{net_instance_id: net_instance_id}) do
    %__MODULE__{net_instance_id: net_instance_id}
  end

  def multi(%__MODULE__{net_instance_id: net_instance_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(ins in SimulationNetInstance,
        where: ins.id == ^net_instance_id
      )
    )
  end
end
