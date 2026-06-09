defmodule RenewCollabWeb.SimulationController do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabSim.Entities.Simulation

  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

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
        render(conn, :created, simulation: simulation)

      {:error, :invalid_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "The document is not a valid Renew file"})
        |> halt()

      {:error, :export_rnw} ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Conversion to Renew format failed"})
        |> halt()

      _ ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Compiling the shadow net system failed"})
        |> halt()
    end
  end

  def delete(conn, %{"simulation_id" => simulation_id}) do
    %Actions.SimulationDeleteAsUser{simulation_id: simulation_id}
    |> Dispatcher.perform_as(conn.assigns.current_account)

    conn
    |> put_status(:ok)
    |> halt()
  end

  def show(conn, %{"id" => simulation_id}) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(conn.assigns.current_account)
    |> case do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Simulation not found"})
        |> halt()

      sim ->
        render(conn, :show,
          simulation: sim,
          running:
            %Views.SimulationIsActive{
              project_id: sim.project_assignment.project_id,
              simulation_id: simulation_id
            }
            |> Fetcher.fetch_as(conn.assigns.current_account)
        )
    end
  end

  def log(conn, %{"id" => simulation_id}) do
    sim =
      %Views.SimulationWithLogEntries{
        simulation_id: simulation_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :log,
      simulation_id: simulation_id,
      log_entries: sim.log_entries
    )
  end

  def show_sns(conn, %{"id" => sns_id}) do
    sns =
      %Views.ShadowNetSystem{
        shadow_net_system_id: sns_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :show_sns, sns: sns)
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
    net_instance =
      %Views.SimulationNetInstanceByName{
        simulation_id: simulation_id,
        net_name: net_name,
        integer_id: integer_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :show_instance, net_instance: net_instance)
  end

  def formalisms(conn, %{}) do
    render(conn, :formalisms, formalisms: RenewCollabSim.Compiler.SnsCompiler.formalisms())
  end
end
