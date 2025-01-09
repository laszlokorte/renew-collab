defmodule RenewCollabSim.Commands.ConsumeToken do
  import Ecto.Query

  defstruct [:simulation_id, :instance_name, :instance_number, :place_id, :value]

  def new(%{
        simulation_id: simulation_id,
        instance_name: instance_name,
        instance_number: instance_number,
        place_id: place_id,
        value: value
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      instance_name: instance_name,
      instance_number: instance_number,
      place_id: place_id,
      value: value
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          instance_name: instance_name,
          instance_number: instance_number,
          place_id: place_id,
          value: value
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      {step_counter, :find_remove_tokens},
      from(t in RenewCollabSim.Entites.SimulationNetToken,
        select: t.id,
        limit: 1,
        join: i in assoc(t, :simulation_net_instance),
        where:
          t.value == ^value and
            t.place_id == ^place_id and
            t.simulation_id == ^simulation_id and
            i.label == ^"#{instance_name}[#{instance_number}]"
      )
      |> then(fn q ->
        Ecto.Adapters.SQL.to_sql(:all, Repo, q)

        q
      end)
    )
    |> Ecto.Multi.delete_all(
      {step_counter, :remove_tokens},
      fn
        %{{^step_counter, :find_remove_tokens} => nil} ->
          from(dt in RenewCollabSim.Entites.SimulationNetToken,
            where: false
          )

        %{{^step_counter, :find_remove_tokens} => to_delete} ->
          from(dt in RenewCollabSim.Entites.SimulationNetToken,
            where: dt.id == ^to_delete
          )
      end
    )
  end
end
