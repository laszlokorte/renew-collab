defmodule RenewCollabWeb.SyntaxController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views

  action_fallback RenewCollabWeb.FallbackController

  def list(conn, %{}) do
    render(conn, :list, %{
      syntaxes:
        %Views.GlobalSyntaxList{}
        |> Fetcher.fetch_as(conn.assigns.current_account)
    })
  end

  def rules(conn, %{"id" => id}) do
    render(conn, :rules, %{syntax: RenewCollab.Syntax.find(id)})
  end
end
