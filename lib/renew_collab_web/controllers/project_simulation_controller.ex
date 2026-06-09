defmodule RenewCollabWeb.ProjectSimulationController do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabSim.Entities.Simulation
  alias RenewCollabWeb.SimulationError
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"project_id" => project_id}) do
    render(conn, :index,
      project_id: project_id,
      simulations:
        %Views.ProjectSimulationsList{
          project_id: project_id
        }
        |> Fetcher.fetch_as(conn.assigns.current_account),
      runnings:
        %Views.ProjectRunningSimulationIds{
          project_id: project_id
        }
        |> Fetcher.fetch_as(conn.assigns.current_account)
    )
  end

  def create(conn, params = %{"project_id" => project_id, "document_ids" => document_ids})
      when is_list(document_ids) do
    formalism =
      Map.get(params, "formalism", RenewCollabSim.Compiler.SnsCompiler.default_formalism())

    %Actions.SimulationCreateFromDocumentsInProject{
      project_id: project_id,
      document_ids: document_ids,
      formalism: formalism,
      main_net_name: Map.get(params, "main_net_name")
    }
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, %Simulation{} = simulation} ->
        conn
        |> put_status(:created)
        |> Phoenix.Controller.json(%{id: simulation.id})
        |> halt()

      {:error, :invalid_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          error: "invalid_rnw",
          message: "The document is not a valid Renew file",
          detail: SimulationError.detail(:invalid_rnw)
        })
        |> halt()

      {:error, :export_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          error: "export_rnw",
          message: "Conversion to Renew format failed",
          detail: SimulationError.detail(:export_rnw)
        })
        |> halt()

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          error: "simulation_create_failed",
          message: "Compiling the shadow net system failed",
          detail: SimulationError.detail(reason)
        })
        |> halt()

      reason ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          error: "simulation_create_failed",
          message: "Compiling the shadow net system failed",
          detail: SimulationError.detail(reason)
        })
        |> halt()
    end
  end
end
