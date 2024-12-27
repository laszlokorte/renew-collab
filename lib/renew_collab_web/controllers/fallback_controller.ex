defmodule RenewCollabWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RenewCollabWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: RenewCollabWeb.ErrorHTML, json: RenewCollabWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(html: RenewCollabWeb.ErrorHTML, json: RenewCollabWeb.ErrorJSON)
    |> render(:"401")
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(html: RenewCollabWeb.ErrorHTML, json: RenewCollabWeb.ErrorJSON)
    |> render(:"403")
  end
end
