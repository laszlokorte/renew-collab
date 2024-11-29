defmodule RenewCollabWeb.SimulationController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{}) do
    render(conn, :index, simulations: RenewCollabSim.Simulator.find_all_simulations())
  end

  def create(conn, %{"document_ids" => document_ids}) when is_list(document_ids) do
    conn |> redirect(url(~p"/api/simulations"))
  end

  def delete(conn, %{"simulation_id" => simulation_id}) do
    conn |> redirect(url(~p"/api/simulations"))
  end

  def show(conn, %{"id" => simulation_id}) do
    render(conn, :show, simulation: RenewCollabSim.Simulator.find_simulation(simulation_id))
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
