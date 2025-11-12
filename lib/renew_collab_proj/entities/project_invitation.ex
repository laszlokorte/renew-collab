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
    |> cast(attrs, [:project_id, :account_id, :email, :role])
    |> validate_required([:project_id, :email, :role])
    |> unique_constraint([:project_id, :email])
    |> unique_constraint([:project_id, :account_id],
      name: "project_invitation_project_id_account_id_index"
    )
  end
end
