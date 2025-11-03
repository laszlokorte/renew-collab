defmodule RenewCollabWeb.ProjectSimulationController do
  alias RenewCollabSim.Server.ScopedSimulationServer
  alias RenewCollabSim.Entities.Simulation
  alias RenewCollabProj.Projects
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"project_id" => project_id}) do
    render(conn, :index,
      project_id: project_id,
      simulations:
        RenewCollabSim.Simulator.list_simulations(
          RenewCollabProj.Projects.list_project_simulations(project_id)
        ),
      runnings: ScopedSimulationServer.running_ids(project_id) |> MapSet.new()
    )
  end

  def create(conn, params = %{"project_id" => project_id, "document_ids" => document_ids})
      when is_list(document_ids) do
    formalism =
      Map.get(params, "formalism", RenewCollabSim.Compiler.SnsCompiler.default_formalism())

    project =
      Projects.find_own_project(conn.assigns.current_account, project_id)

    case RenewCollabSim.Simulator.create_simulation_from_documents(
           project,
           formalism,
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
end
