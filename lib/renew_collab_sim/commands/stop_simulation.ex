defmodule RenewCollabSim.Commands.StopSimulation do
  import Ecto.Query

  defstruct [:simulation_id, exit_code: nil]

  def new(%{
        simulation_id: simulation_id,
        exit_code: exit_code
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      exit_code: exit_code
    }
  end

  def new(%{
        simulation_id: simulation_id
      }) do
    %__MODULE__{
      simulation_id: simulation_id
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          exit_code: exit_code
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      {step_counter, :make_log_entry},
      %RenewCollabSim.Entites.SimulationLogEntry{
        simulation_id: simulation_id,
        content:
          if exit_code do
            "simulation process exit: #{exit_code}"
          else
            "simulation stopped"
          end
      }
    )
    |> Ecto.Multi.delete_all(
      {step_counter, :delete_net_instances},
      from(i in RenewCollabSim.Entites.SimulationNetInstance,
        where: i.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.update_all(
      {step_counter, :reset_timestep},
      from(sim in RenewCollabSim.Entites.Simulation,
        where: sim.id == ^simulation_id,
        update: [set: [timestep: 0]]
      ),
      []
    )
  end
end
