defmodule RenewCollabWeb.SimulationController do
  alias RenewCollabSim.Server.SimulationServer
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{}) do
    render(conn, :index,
      simulations: RenewCollabSim.Simulator.find_all_simulations(),
      runnings: SimulationServer.running_ids() |> MapSet.new()
    )
  end

  def create(conn, params = %{"document_ids" => [first_id | _] = document_ids})
      when is_list(document_ids) do
    nets =
      try do
        document_ids
        |> Enum.map(fn doc_id ->
          document = RenewCollab.Renew.get_document_with_elements(doc_id)
          {:ok, rnw} = RenewCollab.Export.DocumentExport.export(document)
          {:ok, json} = RenewCollabWeb.DocumentJSON.show_content(document) |> Jason.encode()

          {document.name, rnw, json}
        end)
      rescue
        _ ->
          :export_error
      end

    with [{default_main_name, _, _} | _] <- nets,
         main_name <- Map.get(params, "main_net_name", default_main_name),
         {:ok, content} <-
           RenewCollabSim.Compiler.SnsCompiler.compile(
             nets
             |> Enum.map(fn {name, rnw, json} -> {name, rnw} end)
           ),
         {:ok, %{id: sns_id}} <-
           %RenewCollabSim.Entites.ShadowNetSystem{}
           |> RenewCollabSim.Entites.ShadowNetSystem.changeset(%{
             "compiled" => content,
             "main_net_name" => main_name,
             "nets" =>
               nets
               |> Enum.map(fn {name, rnw, json} ->
                 %{
                   "name" => name,
                   "document_json" => json
                 }
               end)
           })
           |> RenewCollab.Repo.insert() do
      %RenewCollabSim.Entites.Simulation{
        shadow_net_system_id: sns_id
      }
      |> RenewCollab.Repo.insert()
      |> case do
        {:ok, %{id: sim_id} = simulation} ->
          RenewCollabSim.Server.SimulationServer.setup(sim_id)

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "shadow_net:#{sns_id}",
            :any
          )

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "simulations",
            {:simulation_change, sim_id, :created}
          )

          render(conn, :created, simulation: simulation)

        _ ->
          conn
          |> put_status(:bad_request)
          |> Phoenix.Controller.json(%{message: "Not a valid renew file"})
          |> halt()
      end
    else
      :export_error ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Conversion to .rnw failed"})
        |> halt()

      x ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Compilation to SNS Failed"})
        |> halt()
    end
  end

  def delete(conn, %{"simulation_id" => simulation_id}) do
    conn |> redirect(url(~p"/api/simulations"))
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
