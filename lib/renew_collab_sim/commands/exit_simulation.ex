# |> Ecto.Multi.insert(
#       {om_counter, :make_log_entry},
#       %RenewCollabSim.Entites.SimulationLogEntry{
#         simulation_id: simulation_id,
#         content: "simulation process exit: #{status}"
#       }
#     )
#     |> Ecto.Multi.delete_all(
#       {om_counter, :delete_net_instances},
#       from(i in RenewCollabSim.Entites.SimulationNetInstance,
#         where: i.simulation_id == ^simulation_id
#       )
#     )
#     |> Ecto.Multi.update_all(
#       {om_counter, :reset_timestep},
#       from(sim in RenewCollabSim.Entites.Simulation,
#         where: sim.id == ^simulation_id,
#         update: [set: [timestep: 0]]
#       ),
#       []
#     )
