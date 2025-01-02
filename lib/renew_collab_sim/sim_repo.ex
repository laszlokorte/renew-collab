defmodule RenewCollabSim.Repo do
  @db_adapter Application.compile_env(:renew_collab, :db_sim_adapter)

  use Ecto.Repo,
    otp_app: :renew_collab,
    adapter: @db_adapter
end
