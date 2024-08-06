defmodule RenewCollabWeb.Plug.Authenticate do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- RenewCollabWeb.Token.verify(token) do
      conn
      |> assign(:current_user, data.user_id)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{"error" => "Not authorized"})
        |> halt()
    end
  end
end
