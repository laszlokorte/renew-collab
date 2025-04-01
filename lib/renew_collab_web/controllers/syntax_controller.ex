defmodule RenewCollabWeb.SyntaxController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def rules(conn, %{"id" => _id}) do
    render(conn, :rules, %{})
  end
end
