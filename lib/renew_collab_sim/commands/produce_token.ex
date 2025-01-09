defmodule RenewCollabSim.Commands.ProduceToken do
  import Ecto.Query

  defstruct [:simulation_id, :instance_name, :instance_number, :place_id, :value]

  def new(%{
        simulation_id: simulation_id,
        instance_name: instance_name,
        instance_number: instance_number,
        place_id: place_id,
        value: value
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      instance_name: instance_name,
      instance_number: instance_number,
      place_id: place_id,
      value: value
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          instance_name: instance_name,
          instance_number: instance_number,
          place_id: place_id,
          value: value
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      {step_counter, :find_instance_for_init_tokens},
      from(n in RenewCollabSim.Entites.SimulationNetInstance,
        where:
          n.label == ^"#{instance_name}[#{instance_number}]" and
            n.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.insert(
      {step_counter, :init_tokens},
      fn %{{^step_counter, :find_instance_for_init_tokens} => n} ->
        %RenewCollabSim.Entites.SimulationNetToken{
          simulation_id: n.simulation_id,
          simulation_net_instance_id: n.id,
          place_id: place_id,
          value: value
        }
      end
    )
  end
end
