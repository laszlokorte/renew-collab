defmodule RenewCollabWeb.InvitationController do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :controller

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, _params) do
    render(conn, :index,
      invitations:
        %Views.MyProjectInvitations{
          account_id: conn.assigns.current_account.id
        }
        |> Fetcher.fetch_as(conn.assigns.current_account)
    )
  end
end
