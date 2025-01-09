# Ecto.Multi.new()
#            |> Ecto.Multi.one(
#              {om_counter, :find_place_put_tokens},
#              from(n in RenewCollabSim.Entites.SimulationNetInstance,
#                where:
#                  n.label == ^"#{instance_name}[#{instance_number}]" and
#                    n.simulation_id == ^simulation_id
#              )
#            )
#            |> Ecto.Multi.insert(
#              {om_counter, :put_tokens},
#              fn %{{^om_counter, :find_place_put_tokens} => ins} ->
#                %RenewCollabSim.Entites.SimulationNetToken{
#                  simulation_id: ins.simulation_id,
#                  simulation_net_instance_id: ins.id,
#                  place_id: place_id,
#                  value: value
#                }
#              end
#            )
