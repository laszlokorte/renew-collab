defmodule RenewCollabSim.Commands.LogEvent do
  import Ecto.Query

  defstruct [:simulation_id, content: nil]

  def new(%{
        simulation_id: simulation_id,
        content: content
      }) do
    %__MODULE__{
      simulation_id: simulation_id,
      content: content
    }
  end

  def multi(
        %__MODULE__{
          simulation_id: simulation_id,
          content: content
        },
        step_counter
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      {step_counter, :log_entry},
      %RenewCollabSim.Entites.SimulationLogEntry{
        simulation_id: simulation_id,
        content: content
      }
    )
    |> Ecto.Multi.one(
      {step_counter, :oldest_to_keep},
      from(t in RenewCollabSim.Entites.SimulationLogEntry,
        select: t.inserted_at,
        offset: 100,
        limit: 1,
        order_by: [desc: t.inserted_at],
        where: t.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.delete_all(
      {step_counter, :delete_old_logs},
      fn
        %{{^step_counter, :oldest_to_keep} => oldest_to_keep}
        when not is_nil(oldest_to_keep) ->
          from(dt in RenewCollabSim.Entites.SimulationLogEntry,
            where:
              dt.simulation_id == ^simulation_id and
                dt.inserted_at < ^oldest_to_keep
          )

        _ ->
          from(dt in RenewCollabSim.Entites.SimulationLogEntry, where: false)
      end
    )
  end
end
