defmodule RenewCollabSim.Commands.FireTransition do
  import Ecto.Query

  defstruct [
    :simulation_id,
    :shadow_net_system_id,
    :instance_name,
    :instance_number,
    :transition_id,
    :time_number
  ]

  def new(%{
        simulation_id: simulation_id,
        shadow_net_system_id: shadow_net_system_id,
        instance_name: instance_name,
        instance_number: instance_number,
        transition_id: transition_id,
        time_number: time_number
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      shadow_net_system_id: shadow_net_system_id,
      instance_name: instance_name,
      instance_number: instance_number,
      transition_id: transition_id,
      time_number: time_number
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          shadow_net_system_id: shadow_net_system_id,
          instance_name: instance_name,
          instance_number: instance_number,
          transition_id: transition_id,
          time_number: time_number
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      {step_counter, :find_net_instances},
      from(sn in RenewCollabSim.Entites.ShadowNet,
        where:
          sn.name == ^instance_name and
            sn.shadow_net_system_id == ^shadow_net_system_id,
        join: sim in RenewCollabSim.Entites.Simulation,
        on: sim.id == ^simulation_id,
        select: %{
          sim_id: sim.id,
          sns_id: sn.shadow_net_system_id,
          net_id: sn.id
        }
      )
    )
    |> Ecto.Multi.insert(
      {step_counter, :create_net_instances},
      fn %{
           {^step_counter, :find_net_instances} => %{
             sim_id: sim_id,
             sns_id: sns_id,
             net_id: net_id
           }
         } ->
        %RenewCollabSim.Entites.SimulationNetInstance{}
        |> Ecto.Changeset.change(%{
          simulation_id: sim_id,
          label: "#{instance_name}[#{instance_number}]",
          shadow_net_system_id: sns_id,
          shadow_net_id: net_id,
          integer_id: String.to_integer(instance_number)
        })
        |> Ecto.Changeset.unique_constraint(:label,
          name: :simulation_net_instance_simulation_id_label_index
        )
      end,
      on_conflict: :nothing
    )
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
