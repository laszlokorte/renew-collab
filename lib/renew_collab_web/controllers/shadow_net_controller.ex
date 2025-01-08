defmodule RenewCollabWeb.ShadowNetController do
  use RenewCollabWeb, :controller

  alias RenewCollabSim.Simulator

  action_fallback RenewCollabWeb.FallbackController

  def download(conn, %{"id" => id}) do
    content_type =
      with %{query_params: %{"text" => _}} <- conn do
        "text/plain"
      else
        _ -> "application/binary"
      end

    Simulator.find_shadow_net_system(id)
    |> case do
      %{compiled: compiled} ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{id}.sns\""
        )
        |> put_resp_header(
          "content-type",
          content_type
        )
        |> send_resp(:ok, compiled)

      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not Found"})
        |> halt()
    end
  end

  def create_simulation(conn, %{"id" => id}) do
    Simulator.find_shadow_net_system(id)
    |> case do
      %{id: sns_id} ->
        RenewCollabSim.Simulator.create_simulation(sns_id)
        |> case do
          {:ok, %{id: id}} ->
            conn
            |> put_status(:ok)
            |> Phoenix.Controller.json(%{id: id})
        end

      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not Found"})
        |> halt()
    end
  end
end
