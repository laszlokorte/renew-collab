defmodule RenewCollab.Simulation.SimulationLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "document_snapshot_simulation" do
    belongs_to :document, RenewCollab.Document.Document
    belongs_to :snapshot, RenewCollab.Versioning.Snapshot

    field :simulation_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sim_link, attrs) do
    sim_link
    |> cast(attrs, [:document_id, :snapshot_id, :simulation_id])
    |> validate_required([:document_id, :snapshot_id, :simulation_id])
  end
end
