defmodule RenewCollabWeb.SimulationController do
  alias RenewCollabSim.Server.SimulationServer
  alias RenewCollabSim.Entites.Simulation

  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{}) do
    render(conn, :index,
      simulations: RenewCollabSim.Simulator.find_all_simulations(),
      runnings: SimulationServer.running_ids() |> MapSet.new()
    )
  end

  def create(conn, params = %{"document_ids" => document_ids})
      when is_list(document_ids) do
    case RenewCollabSim.Simulator.create_simulation_from_documents(
           document_ids,
           Map.get(params, "main_net_name")
         ) do
      %Simulation{} = simulation ->
        render(conn, :created, simulation: simulation)

      {:error, :invalid_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Not a valid renew file"})
        |> halt()

      {:error, :export_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Conversion to rnw file failed"})
        |> halt()

      _ ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Compiling SSN failed"})
        |> halt()
    end
  end

  def delete(conn, %{"simulation_id" => simulation_id}) do
    RenewCollabSim.Simulator.delete_simulation(simulation_id)
    RenewCollabSim.Server.SimulationServer.terminate(simulation_id)

    conn
    |> put_status(:ok)
    |> halt()
  end

  def show(conn, %{"id" => simulation_id}) do
    render(conn, :show,
      simulation: RenewCollabSim.Simulator.find_simulation(simulation_id),
      running: RenewCollabSim.Server.SimulationServer.exists(simulation_id)
    )
  end

  def show_sns(conn, %{"id" => sns_id}) do
    render(conn, :show_sns, sns: RenewCollabSim.Simulator.find_shadow_net_system(sns_id))
  end

  def step(conn, %{"id" => simulation_id}) do
    render(conn, :step, status: :ok, simulation_id: simulation_id)
  end

  def terminate(conn, %{"id" => simulation_id}) do
    render(conn, :terminate, status: :ok, simulation_id: simulation_id)
  end

  def show_instance(conn, %{
        "id" => simulation_id,
        "net_name" => net_name,
        "integer_id" => integer_id
      }) do
    render(conn, :show_instance,
      net_instance:
        RenewCollabSim.Simulator.find_simulation_net_instance(simulation_id, net_name, integer_id)
    )
  end
end
