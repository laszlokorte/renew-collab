defmodule RenewCollab.Repo do
  use Ecto.Repo,
    otp_app: :renew_collab,
    adapter: Ecto.Adapters.MyXQL
end
