defmodule RenewCollabWeb.SyntaxController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def list(conn, %{}) do
    render(conn, :list, %{
      syntaxes: RenewCollab.Syntax.find_all()
    })
  end

  def rules(conn, %{"id" => id}) do
    render(conn, :rules, %{syntax: RenewCollab.Syntax.find(id)})
  end
end
