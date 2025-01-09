# Ecto.Multi.new()
#            |> Ecto.Multi.one(
#              {om_counter, :find_transition_firing},
#              from(n in RenewCollabSim.Entites.SimulationNetInstance,
#                where:
#                  n.label == ^"#{instance_name}[#{instance_number}]" and
#                    n.simulation_id == ^simulation_id,
#                select: %{
#                  simulation_id: n.simulation_id,
#                  id: n.id
#                }
#              )
#            )
#            |> Ecto.Multi.insert(
#              {om_counter, :track_firing},
#              fn %{{^om_counter, :find_transition_firing} => n} ->
#                %RenewCollabSim.Entites.SimulationTransitionFiring{
#                  simulation_id: n.simulation_id,
#                  simulation_net_instance_id: n.id,
#                  transition_id: transition_id,
#                  timestep: String.to_integer(time_number)
#                }
#              end
#            )
