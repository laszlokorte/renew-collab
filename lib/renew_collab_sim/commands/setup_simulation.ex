defmodule RenewCollabSim.Commands.SetupSimulation do
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{
        simulation_id: simulation_id
      }) do
    %__MODULE__{
      simulation_id: simulation_id
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      {step_counter, :update_time},
      from(sim in RenewCollabSim.Entites.Simulation,
        where: sim.id == ^simulation_id,
        update: [set: [timestep: 1]]
      ),
      []
    )
  end
end
