defmodule RenewCollabWeb.InvitationController do
  use RenewCollabWeb, :controller

  alias RenewCollab.ViewBox
  alias RenewCollab.Document.Document
  alias RenewCollab.Import.DocumentImport
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher

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
