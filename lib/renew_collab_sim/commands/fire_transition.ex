defmodule RenewCollabSim.Commands.FireTransition do
  import Ecto.Query

  defstruct [:simulation_id, :instance_name, :instance_number, :transition_id, :time_number]

  def new(%{
        simulation_id: simulation_id,
        instance_name: instance_name,
        instance_number: instance_number,
        transition_id: transition_id,
        time_number: time_number
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      instance_name: instance_name,
      instance_number: instance_number,
      transition_id: transition_id,
      time_number: time_number
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          instance_name: instance_name,
          instance_number: instance_number,
          transition_id: transition_id,
          time_number: time_number
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      {step_counter, :find_transition_firing},
      from(n in RenewCollabSim.Entites.SimulationNetInstance,
        where:
          n.label == ^"#{instance_name}[#{instance_number}]" and
            n.simulation_id == ^simulation_id,
        select: %{
          simulation_id: n.simulation_id,
          id: n.id
        }
      )
    )
    |> Ecto.Multi.insert(
      {step_counter, :track_firing},
      fn %{{^step_counter, :find_transition_firing} => n} ->
        %RenewCollabSim.Entites.SimulationTransitionFiring{
          simulation_id: n.simulation_id,
          simulation_net_instance_id: n.id,
          transition_id: transition_id,
          timestep: String.to_integer(time_number)
        }
      end
    )
  end
end
