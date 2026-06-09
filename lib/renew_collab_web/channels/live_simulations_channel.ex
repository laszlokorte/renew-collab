defmodule RenewCollabWeb.LiveSimulationsChannel do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias LiveState.Event
  alias RenewCollabWeb.SimulationError
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("project-simulations:" <> project_id, _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "projects/#{project_id}/simulations")

    account = socket.assigns.current_account

    %Views.ProjectSimulationsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      sims when is_list(sims) ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-project-simulations:#{project_id}")

        {:ok,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             %Views.ProjectRunningSimulationIds{
               project_id: project_id
             }
             |> Fetcher.fetch_as(account)
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
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      sims when is_list(sims) ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             %Views.ProjectRunningSimulationIds{
               project_id: project_id
             }
             |> Fetcher.fetch_as(account)
         })}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, _},
        %{project_id: project_id},
        %{project_id: project_id, account: account}
      ) do
    %Views.ProjectSimulationsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      sims when is_list(sims) ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.index_content(%{
           project_id: project_id,
           simulations: sims,
           runnings:
             %Views.ProjectRunningSimulationIds{
               project_id: project_id
             }
             |> Fetcher.fetch_as(account)
         })}
    end
  end

  @impl true
  def handle_message(
        {:simulation_error, {_simulation_id, error}},
        state,
        _scope
      ) do
    {:reply, %Event{name: "error", detail: error}, state}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event(
        "step",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        socket
      ) do
    %Actions.SimulationStep{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_step_failed",
      "Simulation step could not be performed"
    )
  end

  @impl true
  def handle_event(
        "stop",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        socket
      ) do
    %Actions.SimulationTerminate{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_terminate_failed",
      "Simulation could not be terminated"
    )
  end

  @impl true
  def handle_event(
        "start",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        socket
      ) do
    %Actions.SimulationInitialize{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_init_failed",
      "Simulation could not be initialized"
    )
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => simulation_id},
        _state,
        %{account: account},
        socket
      ) do
    %Actions.SimulationDeleteAsUser{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_delete_failed",
      "Simulation could not be deleted"
    )
  end

  defp perform_simulation_action(action, account, socket, error, message) do
    try do
      Dispatcher.perform_as(action, account)
    rescue
      exception -> {:error, exception}
    catch
      :exit, reason -> {:error, reason}
      kind, reason -> {:error, {kind, reason}}
    end
    |> handle_simulation_result(socket, error, message)
  end

  defp handle_simulation_result(result, socket, error, message) do
    case result do
      :ok ->
        :ack

      {:ok, _} ->
        :ack

      true ->
        :ack

      false ->
        push_simulation_error(socket, error, message, "The simulation is not running.")

      {:error, reason} ->
        push_simulation_error(socket, error, message, SimulationError.detail(reason))

      reason ->
        push_simulation_error(socket, error, message, SimulationError.detail(reason))
    end
  end

  defp push_simulation_error(socket, error, message, detail) do
    push_error(socket, %{
      error: error,
      message: message,
      detail: detail
    })

    :ack
  end
end
