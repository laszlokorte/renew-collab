# |> Ecto.Multi.update_all(
#           {om_counter, :reset_time},
#           from(sim in RenewCollabSim.Entites.Simulation,
#             where: sim.id == ^simulation_id,
#             update: [set: [timestep: 1]]
#           ),
#           []
#         )
