defmodule RenewCollab.Commands.LinkDocumenstToSimulation do
  alias RenewCollab.Simulation.SimulationLink

  defstruct [:simulation_id, :document_ids]

  def new(%{simulation_id: simulation_id, document_ids: document_ids}) do
    %__MODULE__{simulation_id: simulation_id, document_ids: document_ids}
  end

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{simulation_id: sim_id, document_ids: document_ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(
      :link_documents,
      SimulationLink,
      for {document_id, snapshot_id} <- document_ids do
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        %{
          simulation_id: sim_id,
          document_id: document_id,
          snapshot_id: snapshot_id,
          inserted_at: now,
          updated_at: now
        }
      end
    )
  end
end
