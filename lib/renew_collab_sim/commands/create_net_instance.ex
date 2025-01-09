# Ecto.Multi.new()
#            |> Ecto.Multi.one(
#              {om_counter, :find_net_instances},
#              from(sn in RenewCollabSim.Entites.ShadowNet,
#                where:
#                  sn.name == ^instance_name and
#                    sn.shadow_net_system_id == ^simulation.shadow_net_system_id,
#                join: sim in RenewCollabSim.Entites.Simulation,
#                on: sim.id == ^simulation_id,
#                select: %{
#                  sim_id: sim.id,
#                  sns_id: sn.shadow_net_system_id,
#                  net_id: sn.id
#                }
#              )
#            )
#            |> Ecto.Multi.insert(
#              {om_counter, :create_net_instances},
#              fn %{
#                   {^om_counter, :find_net_instances} => %{
#                     sim_id: sim_id,
#                     sns_id: sns_id,
#                     net_id: net_id
#                   }
#                 } ->
#                %RenewCollabSim.Entites.SimulationNetInstance{
#                  simulation_id: sim_id,
#                  label: "#{instance_name}[#{instance_number}]",
#                  shadow_net_system_id: sns_id,
#                  shadow_net_id: net_id,
#                  integer_id: String.to_integer(instance_number)
#                }
#              end
#            )
#            |> Ecto.Multi.delete_all(
#              {om_counter, :delete_old_tokens},
#              from(dt in RenewCollabSim.Entites.SimulationNetToken,
#                where:
#                  dt.simulation_net_instance_id in subquery(
#                    from(i in RenewCollabSim.Entites.SimulationNetInstance,
#                      select: i.id,
#                      where:
#                        i.simulation_id == ^simulation_id and
#                          i.label == ^"#{instance_name}[#{instance_number}]"
#                    )
#                  )
#              )
#            )
