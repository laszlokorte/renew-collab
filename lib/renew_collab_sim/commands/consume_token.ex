# Ecto.Multi.new()
#            |> Ecto.Multi.one(
#              {om_counter, :find_remove_tokens},
#              from(t in RenewCollabSim.Entites.SimulationNetToken,
#                select: t.id,
#                limit: 1,
#                join: i in assoc(t, :simulation_net_instance),
#                where:
#                  t.value == ^value and
#                    t.place_id == ^place_id and
#                    t.simulation_id == ^simulation_id and
#                    i.label == ^"#{instance_name}[#{instance_number}]"
#              )
#              |> then(fn q ->
#                Ecto.Adapters.SQL.to_sql(:all, Repo, q)

#                q
#              end)
#            )
#            |> Ecto.Multi.delete_all(
#              {om_counter, :remove_tokens},
#              fn
#                %{{^om_counter, :find_remove_tokens} => nil} ->
#                  from(dt in RenewCollabSim.Entites.SimulationNetToken,
#                    where: false
#                  )

#                %{{^om_counter, :find_remove_tokens} => to_delete} ->
#                  from(dt in RenewCollabSim.Entites.SimulationNetToken,
#                    where: dt.id == ^to_delete
#                  )
#              end
#            )
#          )
