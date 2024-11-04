defmodule RenewCollabWeb.Auth do
  use RenewCollabWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias RenewCollabAuth.Auth

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_live_view_studio_web_account_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def log_in_account(conn, account, params \\ %{}) do
    token = Auth.generate_account_session_token(account)
    account_return_to = get_session(conn, :account_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: account_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  def log_out_account(conn) do
    account_token = get_session(conn, :account_token)
    account_token && Auth.delete_account_session_token(account_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      RenewCollabWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/login")
  end

  def fetch_current_account(conn, _opts) do
    {account_token, conn} = ensure_account_session_token(conn)
    account = account_token && Auth.get_account_by_session_token(account_token)
    assign(conn, :current_account, account)
  end

  def fetch_current_account_by_header(conn, _opts) do
    with {%{account_id: account_id}, conn} <- ensure_account_header_token(conn),
         account <- Auth.get_account!(account_id) do
      assign(conn, :current_account, account)
    else
      _ ->
        conn
    end
  end

  defp ensure_account_header_token(conn) do
    if token = get_auth_header(conn) do
      with {:ok, data} <- RenewCollabWeb.Token.verify(token) do
        {data, conn}
      else
        _ ->
          {nil, conn}
      end
    else
      {nil, conn}
    end
  end

  defp ensure_account_session_token(conn) do
    if token = get_session(conn, :account_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  defp get_auth_header(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      token
    else
      _ -> nil
    end
  end

  def on_mount(:mount_current_account, _params, session, socket) do
    {:cont, mount_current_account(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_account(socket, session)

    if socket.assigns.current_account do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_account_is_authenticated, _params, session, socket) do
    socket = mount_current_account(socket, session)

    if socket.assigns.current_account do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_account(socket, session) do
    Phoenix.Component.assign_new(socket, :current_account, fn ->
      if account_token = session["account_token"] do
        Auth.get_account_by_session_token(account_token)
      end
    end)
  end

  def redirect_if_account_is_authenticated(conn, _opts) do
    if conn.assigns[:current_account] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_account(conn, redirect \\ true) do
    if conn.assigns[:current_account] do
      conn
    else
      if redirect do
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> maybe_store_return_to()
        |> redirect(to: ~p"/login")
        |> halt()
      else
        conn
        |> put_status(:unauthorized)
        |> json(%{"message" => "not authorized"})
        |> halt()
      end
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:account_token, token)
    |> put_session(:live_socket_id, "accounts_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :account_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
