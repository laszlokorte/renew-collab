# Ecto.Multi.update_all(
#           {om_counter, :update_time},
#           from(sim in RenewCollabSim.Entites.Simulation,
#             where: sim.id == ^simulation_id,
#             update: [set: [timestep: ^time_number]]
#           ),
#           []
#         )
