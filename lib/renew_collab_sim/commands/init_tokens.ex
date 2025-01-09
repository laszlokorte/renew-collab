# Ecto.Multi.new()
#            |> Ecto.Multi.one(
#              {om_counter, :find_instance_for_init_tokens},
#              from(n in RenewCollabSim.Entites.SimulationNetInstance,
#                where:
#                  n.label == ^"#{instance_name}[#{instance_number}]" and
#                    n.simulation_id == ^simulation_id
#              )
#            )
#            |> Ecto.Multi.insert(
#              {om_counter, :init_tokens},
#              fn %{{^om_counter, :find_instance_for_init_tokens} => n} ->
#                %RenewCollabSim.Entites.SimulationNetToken{
#                  simulation_id: n.simulation_id,
#                  simulation_net_instance_id: n.id,
#                  place_id: place_id,
#                  value: value
#                }
#              end
#            )
