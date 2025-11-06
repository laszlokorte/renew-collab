defmodule RenewCollabWeb.ReduxSimulationsChannel do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("project-simulations:" <> project_id, _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "projects/#{project_id}/simulations")

    %Views.ProjectSimulationsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      sims ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-project-simulations:#{project_id}")

        {:ok,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id) |> MapSet.new()
         }), %{project_id: project_id, account: socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message(
        :simulations_changed,
        %{project_id: project_id},
        %{project_id: project_id, account: account}
      ) do
    %Views.ProjectSimulationsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      sims ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id) |> MapSet.new()
         })}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, _simulation_id, _},
        %{project_id: project_id},
        %{project_id: project_id, account: account}
      ) do
    %Views.ProjectSimulationsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      sims ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id) |> MapSet.new()
         })}
    end
  end

  @impl true
  def handle_message(_, state, {:project_id, _project_id}) do
    {:noreply, state}
  end

  @impl true
  def handle_event(
        "step",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        _socket
      ) do
    %Actions.SimulationStep{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "stop",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        _socket
      ) do
    %Actions.SimulationTerminate{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "start",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        _socket
      ) do
    %Actions.SimulationInitialize{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        _socket
      ) do
    %Actions.SimulationDeleteAsUser{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end
end
