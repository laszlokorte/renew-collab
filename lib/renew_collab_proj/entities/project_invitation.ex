defmodule RenewCollabProj.Entities.ProjectInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_invitation" do
    belongs_to :project, RenewCollabProj.Entities.Project
    belongs_to :account, RenewCollabAuth.Entities.Account
    field :email, :binary
    field :role, Ecto.Enum, values: [:editor, :reader]

    has_one :membership,
      through: [:project, :members],
      foreign_key: :account_id,
      references: :account_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sim, attrs) do
    sim
    |> cast(attrs, [:invitation_id])
    |> validate_required([:project_id, :invitation_id])
  end
end
