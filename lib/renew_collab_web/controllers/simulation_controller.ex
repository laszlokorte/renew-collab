defmodule RenewCollabWeb.SimulationController do
  use RenewCollabWeb, :controller

  alias RenewCollabSim.Entites.Simulation
  alias RenewCollabSim.Simulator

  action_fallback RenewCollabWeb.FallbackController

  def shadow_net_system(conn, %{"id" => id} = p) do
    content_type =
      with %{query_params: %{"text" => _}} <- conn do
        "text/plain"
      else
        _ -> "application/binary"
      end

    Simulator.find_shadow_net_system(id)
    |> case do
      simulation ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{simulation.id}.sns\""
        )
        |> put_resp_header(
          "content-type",
          content_type
        )
        |> send_resp(:ok, simulation.compiled)
    end
  end
end
