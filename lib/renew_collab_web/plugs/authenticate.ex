defmodule RenewCollabWeb.Plug.Authenticate do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with {:ok, token} <- fetch_token(conn),
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

  defp fetch_token(conn) do
    with %{"token" => token} <- conn.query_params do
      {:ok, token}
    else
      _ ->
        with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
          {:ok, token}
        else
          _ ->
            {:error, "no token"}
        end
    end
  end
end
