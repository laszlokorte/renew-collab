defmodule RenewCollabWeb.LiveSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabSim.Entities
  alias LiveState.Event
  alias RenewCollabWeb.SimulationError

  @impl true
  def init("live:simulation:" <> simulation_id, _params, socket) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      %Entities.Simulation{} = sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        account_id = socket.assigns.current_account.id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: nil
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: sim.project_assignment.project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(socket.assigns.current_account),
           %Views.SimulationIsPlaying{
             project_id: sim.project_assignment.project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(socket.assigns.current_account)
         ),
         %{
           project_id: sim.project_assignment.project_id,
           simulation_id: simulation_id,
           account: socket.assigns.current_account
         }}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, {_event, is_playing}}},
        _state,
        %{project_id: project_id, simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(account)
    |> case do
      {:error, :access} ->
        :stop

      nil ->
        :stop

      %Entities.Simulation{} = sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(account),
           is_playing
         )}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, _event}},
        _state,
        %{project_id: project_id, simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(account)
    |> case do
      {:error, :access} ->
        :stop

      nil ->
        :stop

      %Entities.Simulation{} = sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(account),
           false
         )}
    end
  end

  @impl true
  def handle_message(
        {:simulation_error, {simulation_id, error}},
        state,
        %{simulation_id: simulation_id}
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
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
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
        "net_step",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationNetStep{
      simulation_id: simulation_id,
      net_instance_label: payload_value(payload, "net_instance_label")
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_net_step_failed",
      "Simulation net step could not be performed"
    )
  end

  @impl true
  def handle_event(
        "transition_bindings",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    transition_id = payload_value(payload, "transition_id")

    result =
      %Actions.SimulationTransitionBindings{
        simulation_id: simulation_id,
        net_instance_label: payload_value(payload, "net_instance_label"),
        transition_id: transition_id
      }
      |> perform_action(account)

    case result do
      {:ok,
       %{
         bindings: bindings,
         transition_id: result_transition_id,
         transition_instance: transition_instance
       }} ->
        {:reply,
         %{
           transition_id: result_transition_id,
           transition_instance: transition_instance,
           bindings: bindings
         }, socket}

      false ->
        push_error(socket, %{
          error: "transition_bindings_failed",
          message: "Transition bindings could not be loaded",
          detail: "The simulation is not running."
        })

        {:reply, %{transition_id: transition_id, bindings: []}, socket}

      {:error, reason} ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "transition_bindings_failed",
          message: "Transition bindings could not be loaded",
          detail: detail
        })

        {:reply, %{transition_id: transition_id, bindings: [], error: detail}, socket}

      reason ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "transition_bindings_failed",
          message: "Transition bindings could not be loaded",
          detail: detail
        })

        {:reply, %{transition_id: transition_id, bindings: [], error: detail}, socket}
    end
  end

  @impl true
  def handle_event(
        "fire_transition",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    result =
      %Actions.SimulationFireTransition{
        simulation_id: simulation_id,
        net_instance_label: payload_value(payload, "net_instance_label"),
        transition_id: payload_value(payload, "transition_id"),
        binding_index: payload_value(payload, "binding_index")
      }
      |> perform_action(account)

    case result do
      :ok ->
        {:reply, %{fired: true}, socket}

      true ->
        {:reply, %{fired: true}, socket}

      {:ok, _} ->
        {:reply, %{fired: true}, socket}

      false ->
        push_error(socket, %{
          error: "fire_transition_failed",
          message: "Transition could not be fired",
          detail: "The simulation is not running."
        })

        {:reply, %{fired: false}, socket}

      {:error, reason} ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "fire_transition_failed",
          message: "Transition could not be fired",
          detail: detail
        })

        {:reply, %{fired: false, error: detail}, socket}

      reason ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "fire_transition_failed",
          message: "Transition could not be fired",
          detail: detail
        })

        {:reply, %{fired: false, error: detail}, socket}
    end
  end

  @impl true
  def handle_event(
        "play",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationPlay{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_play_failed",
      "Simulation could not be started"
    )
  end

  @impl true
  def handle_event(
        "list_breakpoints",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationListBreakpoints{
      simulation_id: simulation_id
    }
    |> perform_action(account)
    |> handle_breakpoints_result(
      socket,
      "breakpoints_load_failed",
      "Breakpoints could not be loaded"
    )
  end

  @impl true
  def handle_event(
        "set_transition_breakpoint",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationSetTransitionBreakpoint{
      simulation_id: simulation_id,
      transition_id: payload_value(payload, "transition_id")
    }
    |> perform_action(account)
    |> handle_breakpoints_result(socket, "breakpoint_set_failed", "Breakpoint could not be set")
  end

  @impl true
  def handle_event(
        "clear_transition_breakpoint",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationClearTransitionBreakpoint{
      simulation_id: simulation_id,
      transition_id: payload_value(payload, "transition_id")
    }
    |> perform_action(account)
    |> handle_breakpoints_result(
      socket,
      "breakpoint_clear_failed",
      "Breakpoint could not be cleared"
    )
  end

  @impl true
  def handle_event(
        "clear_breakpoints",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationClearBreakpoints{
      simulation_id: simulation_id
    }
    |> perform_action(account)
    |> handle_breakpoints_result(
      socket,
      "breakpoints_clear_failed",
      "Breakpoints could not be cleared"
    )
  end

  @impl true
  def handle_event(
        "pause",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
        socket
      ) do
    %Actions.SimulationPause{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_pause_failed",
      "Simulation could not be paused"
    )
  end

  @impl true
  def handle_event(
        "terminate",
        _payload,
        _state,
        %{simulation_id: simulation_id, account: account},
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
        "init",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          account: account
        },
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

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end

  defp perform_simulation_action(action, account, socket, error, message) do
    action
    |> perform_action(account)
    |> handle_simulation_result(socket, error, message)
  end

  defp perform_action(action, account) do
    try do
      Dispatcher.perform_as(action, account)
    rescue
      exception -> {:error, exception}
    catch
      :exit, reason -> {:error, reason}
      kind, reason -> {:error, {kind, reason}}
    end
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
        push_simulation_error(socket, error, message, simulation_error_detail(reason))

      reason ->
        push_simulation_error(socket, error, message, simulation_error_detail(reason))
    end
  end

  defp handle_breakpoints_result(result, socket, error, message) do
    case result do
      {:ok, breakpoints} when is_list(breakpoints) ->
        {:reply, %{breakpoints: breakpoints}, socket}

      false ->
        push_error(socket, %{
          error: error,
          message: message,
          detail: "The simulation is not running."
        })

        {:reply, %{breakpoints: []}, socket}

      {:error, reason} ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: error,
          message: message,
          detail: detail
        })

        {:reply, %{breakpoints: [], error: detail}, socket}

      reason ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: error,
          message: message,
          detail: detail
        })

        {:reply, %{breakpoints: [], error: detail}, socket}
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

  defp simulation_error_detail(reason), do: SimulationError.detail(reason)

  defp payload_value(payload, key) when is_map(payload) do
    Map.get(payload, key) || Map.get(payload, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.get(payload, key)
  end

  defp payload_value(_payload, _key), do: nil
end
