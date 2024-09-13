defmodule RenewCollabWeb.InstallController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Symbol

  action_fallback RenewCollabWeb.FallbackController

  def reset(conn, _params) do
    Symbol.reset()
    RenewCollab.Renew.reset()

    RenewCollab.Auth.create_account("test@test.de", "secret")

    redirect(conn, to: ~p"/live/documents")
  end
end
