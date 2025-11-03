defmodule RenewCollabWeb.ShadowNetController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Simulator

  action_fallback RenewCollabWeb.FallbackController

  def download(conn, %{"id" => shadow_net_system_id}) do
    content_type =
      with %{query_params: %{"text" => _}} <- conn do
        "text/plain"
      else
        _ -> "application/binary"
      end

    %Views.ShadowNetSystem{shadow_net_system_id: shadow_net_system_id}
    |> Fetcher.fetch_as(conn.assigns.current_account)
    |> case do
      %{compiled: compiled} ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{shadow_net_system_id}.sns\""
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

  def create_simulation(conn, %{"id" => shadow_net_system_id}) do
    %Views.ShadowNetSystem{shadow_net_system_id: shadow_net_system_id}
    |> Fetcher.fetch_as(conn.assigns.current_account)
    |> case do
      %{id: sns_id, project_assignment: %{project_id: project_id}} ->
        %Actions.SimulationCreateFromShadowNetSystemInProject{
          project_id: project_id,
          shadow_net_system_id: shadow_net_system_id
        }
        |> Dispatcher.perform_as(conn.assigns.current_account)
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
