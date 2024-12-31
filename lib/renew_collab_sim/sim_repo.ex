defmodule RenewCollabSim.Repo do
  use Ecto.Repo,
    otp_app: :renew_collab,
    adapter: Application.compile_env(:renew_collab, :db_sim_adapter)
end
