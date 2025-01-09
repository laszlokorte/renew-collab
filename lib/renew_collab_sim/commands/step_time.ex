defmodule RenewCollabSim.Commands.StepTime do
  import Ecto.Query

  defstruct [:simulation_id, :time_number]

  def new(%{
        simulation_id: simulation_id,
        time_number: time_number
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      time_number: time_number
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          time_number: time_number
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      {step_counter, :update_time},
      from(sim in RenewCollabSim.Entites.Simulation,
        where: sim.id == ^simulation_id,
        update: [set: [timestep: ^time_number]]
      ),
      []
    )
  end
end
