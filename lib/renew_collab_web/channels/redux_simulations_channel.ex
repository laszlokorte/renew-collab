defmodule RenewCollabWeb.ReduxSimulationsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("redux_simulations", %{"project_id" => project_id}, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "projects/#{project_id}/simulations")

    {:ok,
     RenewCollabWeb.SimulationJSON.index_content(%{
       project_id: project_id,
       simulations:
         RenewCollabSim.Simulator.list_simulations(
           RenewCollabProj.Projects.list_project_simulations(project_id)
         ),
       runnings: RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new()
     }), socket |> assign(:project_id, project_id)}
  end

  @impl true
  def handle_message({:simulation_change, _simulation_id, _}, %{project_id: project_id}) do
    {:noreply,
     RenewCollabWeb.SimulationJSON.index_content(%{
       project_id: project_id,
       simulations:
         RenewCollabSim.Simulator.list_simulations(
           RenewCollabProj.Projects.list_project_simulations(project_id)
         ),
       runnings: RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new()
     })}
  end

  @impl true
  def handle_message(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_event("step", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.step(id)

    :silent
  end

  @impl true
  def handle_event("stop", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.terminate(id)

    :silent
  end

  @impl true
  def handle_event("start", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.setup(id)

    :silent
  end

  @impl true
  def handle_event("delete", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Simulator.delete_simulation(id)
    RenewCollabSim.Server.SimulationServer.terminate(id)

    :silent
  end
end
