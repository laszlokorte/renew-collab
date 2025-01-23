defmodule RenewCollabSim.Commands.CreateNetInstance do
  import Ecto.Query

  defstruct [:simulation_id, :shadow_net_system_id, :instance_name, :instance_number]

  def new(%{
        simulation_id: simulation_id,
        shadow_net_system_id: shadow_net_system_id,
        instance_name: instance_name,
        instance_number: instance_number
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      shadow_net_system_id: shadow_net_system_id,
      instance_name: instance_name,
      instance_number: instance_number
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          shadow_net_system_id: shadow_net_system_id,
          instance_name: instance_name,
          instance_number: instance_number
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
    |> Ecto.Multi.delete_all(
      {step_counter, :delete_old_tokens},
      from(dt in RenewCollabSim.Entites.SimulationNetToken,
        where:
          dt.simulation_net_instance_id in subquery(
            from(i in RenewCollabSim.Entites.SimulationNetInstance,
              select: i.id,
              where:
                i.simulation_id == ^simulation_id and
                  i.label == ^"#{instance_name}[#{instance_number}]"
            )
          )
      )
    )
  end
end
