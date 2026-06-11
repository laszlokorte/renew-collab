defmodule RenewCollabSim.Server.SimulationProcess do
  use GenServer

  alias RenewCollabSim.Server.SimulationProcess.State

  @simulation_command_timeout 30_000

  def start_monitor(simulation_id, pubsub_channels) do
    with {:ok, pid} <-
           GenServer.start(__MODULE__, %{
             pubsub_channels: pubsub_channels,
             simulation_id: simulation_id,
             latest_update: nil
           }) do
      Process.monitor(pid)
      {:ok, pid}
    else
      e -> e
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def is_playing(pid) do
    GenServer.call(pid, :is_playing)
  end

  def step(pid) do
    GenServer.cast(pid, :step)
  end

  def net_step(pid, net_instance_label) do
    GenServer.cast(pid, {:net_step, net_instance_label})
  end

  def transition_bindings(pid, net_instance_label, transition_id) do
    safe_call(pid, {:transition_bindings, net_instance_label, transition_id})
  end

  def fire_transition(pid, net_instance_label, transition_id, binding_index) do
    safe_call(pid, {:fire_transition, net_instance_label, transition_id, binding_index})
  end

  def list_breakpoints(pid) do
    safe_call(pid, :list_breakpoints)
  end

  def set_transition_breakpoint(pid, transition_id) do
    safe_call(pid, {:set_transition_breakpoint, transition_id})
  end

  def clear_transition_breakpoint(pid, transition_id) do
    safe_call(pid, {:clear_transition_breakpoint, transition_id})
  end

  def clear_breakpoints(pid) do
    safe_call(pid, :clear_breakpoints)
  end

  def play(pid) do
    GenServer.cast(pid, :play)
  end

  def pause(pid) do
    GenServer.cast(pid, :pause)
  end

  defp broadcast_change(
         %{
           simulation_id: sim_id,
           latest_update: latest_update,
           retry: retry,
           playing: playing,
           throttle: {throttle_amount, throttle_unit},
           pubsub_channels: pubsub_channels
         } = state,
         event
       ) do
    now = DateTime.utc_now()

    if retry do
      Process.cancel_timer(retry)
    end

    if is_nil(latest_update) ||
         DateTime.diff(now, latest_update, throttle_unit) >= throttle_amount do
      for channel <- pubsub_channels do
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          channel,
          {:simulation_change, {sim_id, {event, playing}}}
        )
      end

      %{state | latest_update: now, retry: nil}
    else
      %{state | retry: Process.send_after(self(), {:retry_broadcast, event}, 100)}
    end
  end

  defp broadcast_error(
         %{
           simulation_id: sim_id,
           pubsub_channels: pubsub_channels
         } = state,
         detail
       ) do
    payload = simulation_error_payload(detail)

    for channel <- pubsub_channels do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        channel,
        {:simulation_error, {sim_id, payload}}
      )
    end

    state
  end

  defp broadcast_breakpoint_hit(
         %{
           simulation_id: sim_id,
           pubsub_channels: pubsub_channels
         } = state,
         net_instance_label,
         transition_id
       ) do
    payload = %{
      error: "simulation_breakpoint_hit",
      title: "Breakpoint Hit",
      message: "Simulation paused at breakpoint.",
      detail: "Transition #{transition_id} fired in #{net_instance_label}."
    }

    for channel <- pubsub_channels do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        channel,
        {:simulation_error, {sim_id, payload}}
      )
    end

    state
  end

  defp broadcast_breakpoints_changed(
         %{
           simulation_id: sim_id,
           pubsub_channels: pubsub_channels
         } = state
       ) do
    for channel <- pubsub_channels do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        channel,
        {:simulation_change, {sim_id, :breakpoints}}
      )
    end

    state
  end

  defp simulation_error_payload(detail) do
    %{
      error: "simulation_process_failed",
      title: "Simulation Error",
      message: "Renew stopped the simulation before it could be initialized.",
      detail: explain_simulation_error(detail)
    }
  end

  defp explain_simulation_error(detail) when is_binary(detail), do: "Renew reported: #{detail}"

  defp explain_simulation_error(detail), do: inspect(detail)

  @impl true
  def handle_info({:retry_broadcast, event}, state) do
    {:noreply, state |> broadcast_change(event)}
  end

  @impl true
  def handle_info(:auto_step, state) do
    GenServer.cast(self(), :step)
    {:noreply, %{state | scheduled: false}}
  end

  @impl true
  def init(%{simulation_id: simulation_id, pubsub_channels: pubsub_channels}) do
    with {:ok, simulation} when not is_nil(simulation) <-
           RenewCollabSim.Queries.Simulation.new(%{simulation_id: simulation_id})
           |> RenewCollabSim.SimulationFetcher.fetch(),
         {:ok, state} <-
           State.init(
             self(),
             simulation,
             pubsub_channels
           ) do
      {:ok, state}
    else
      error ->
        {:stop, error}
    end
  end

  @impl true
  def handle_call(
        :is_playing,
        _from,
        %{
          playing: is_playing
        } = state
      ) do
    {:reply, is_playing, state}
  end

  @impl true
  def handle_call(
        :stop,
        _from,
        %{
          simulation_id: simulation_id
        } = state
      ) do
    # Is this needed?
    State.destroy(state)

    state
    |> State.append_command(
      RenewCollabSim.Commands.StopSimulation.new(%{simulation_id: simulation_id})
    )
    |> State.commit(:try)
    |> broadcast_change(:stop)
    |> then(&{:stop, :normal, :shutdown_ok, &1})
  end

  @impl true
  def handle_cast(
        {:log, {:exit, status}},
        %{simulation_id: simulation_id} = state
      ) do
    state
    |> State.append_command(
      RenewCollabSim.Commands.StopSimulation.new(%{
        simulation_id: simulation_id,
        exit_code: status
      })
    )
    |> State.commit(:strict)
    |> maybe_broadcast_exit_error(status)
    |> broadcast_change(:stop)
    |> then(&{:stop, :normal, &1})
  end

  @impl true
  def handle_cast(:step, state) do
    State.step(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:net_step, net_instance_label}, state) do
    State.net_step(state, net_instance_label)
    {:noreply, state}
  end

  @impl true
  def handle_call({:transition_bindings, net_instance_label, transition_id}, from, state) do
    request_id = UUID.uuid4(:default)
    State.transition_bindings(state, request_id, net_instance_label, transition_id)

    {:noreply,
     put_in(state.binding_requests[request_id], %{
       from: from,
       transition_id: transition_id,
       transition_instance: nil,
       expected_count: nil,
       bindings: []
     })}
  end

  @impl true
  def handle_call(
        {:fire_transition, net_instance_label, transition_id, binding_index},
        from,
        state
      ) do
    request_id = UUID.uuid4(:default)
    State.fire_transition(state, request_id, net_instance_label, transition_id, binding_index)

    {:noreply,
     put_in(state.fire_requests[request_id], %{
       from: from,
       transition_id: transition_id
     })}
  end

  @impl true
  def handle_call(:list_breakpoints, _from, state) do
    {:reply, {:ok, breakpoint_list(state)}, state}
  end

  @impl true
  def handle_call({:set_transition_breakpoint, transition_id}, _from, state)
      when is_binary(transition_id) do
    breakpoint = %{
      kind: "transition",
      mode: "firing_starts",
      scope: "global",
      transition_id: transition_id
    }

    state = put_in(state.breakpoints[transition_id], breakpoint)
    {:reply, {:ok, breakpoint_list(state)}, broadcast_breakpoints_changed(state)}
  end

  def handle_call({:set_transition_breakpoint, _transition_id}, _from, state) do
    {:reply, {:error, :invalid_transition_id}, state}
  end

  @impl true
  def handle_call({:clear_transition_breakpoint, transition_id}, _from, state)
      when is_binary(transition_id) do
    state = %{state | breakpoints: Map.delete(state.breakpoints, transition_id)}
    {:reply, {:ok, breakpoint_list(state)}, broadcast_breakpoints_changed(state)}
  end

  def handle_call({:clear_transition_breakpoint, _transition_id}, _from, state) do
    {:reply, {:error, :invalid_transition_id}, state}
  end

  @impl true
  def handle_call(:clear_breakpoints, _from, state) do
    state = %{state | breakpoints: %{}}
    {:reply, {:ok, []}, broadcast_breakpoints_changed(state)}
  end

  @impl true
  def handle_cast(:play, state) do
    state = %{state | playing: true}
    State.step(state)
    {:noreply, state |> broadcast_change(:play)}
  end

  @impl true
  def handle_cast(:pause, %{sim_process: _sim_process} = state) do
    # send(sim_process, {:command, "simulation stop\n"})
    {:noreply, %{state | playing: false, scheduled: false} |> broadcast_change(:pause)}
  end

  @impl true
  def handle_cast(
        {:log, {:noeol, content}},
        %{
          simulation_id: simulation_id,
          logging: logging,
          playing: playing
        } = state
      ) do
    state =
      if logging and not playing and not simulation_protocol_line?(content) do
        state
        |> State.append_command(
          RenewCollabSim.Commands.LogEvent.new(%{simulation_id: simulation_id, content: content})
        )
      else
        state
      end
      |> maybe_remember_simulation_error(content)

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:log, {:eol, content}},
        state
      ) do
    process_simulator_output(state, content)
  end

  defp process_simulator_output(
         %{
           simulation_id: simulation_id,
           simulation: simulation,
           playing: playing,
           logging: logging,
           scheduled: scheduled
         } = state,
         content
       ) do
    state =
      if logging and not playing and not simulation_protocol_line?(content) do
        state
        |> State.append_command(
          RenewCollabSim.Commands.LogEvent.new(%{simulation_id: simulation_id, content: content})
        )
      else
        state
      end
      |> maybe_remember_simulation_error(content)

    RenewCollabSim.Server.SimulationParser.parse(content)
    |> case do
      {:new_instance, _time_number, instance_name, instance_number} ->
        {:noreply,
         state
         |> State.append_command(
           RenewCollabSim.Commands.CreateNetInstance.new(%{
             simulation_id: simulation_id,
             shadow_net_system_id: simulation.shadow_net_system_id,
             instance_name: instance_name,
             instance_number: instance_number
           })
         )}

      {:init_token, _time_number, instance_name, instance_number, value, place_id} ->
        {:noreply,
         state
         |> State.append_command(
           RenewCollabSim.Commands.InitToken.new(%{
             simulation_id: simulation_id,
             instance_name: instance_name,
             instance_number: instance_number,
             place_id: place_id,
             value: value
           })
         )}

      {
        :put_token,
        _time_number,
        instance_name,
        instance_number,
        value,
        place_id
      } ->
        {:noreply,
         state
         |> State.append_command(
           RenewCollabSim.Commands.ProduceToken.new(%{
             simulation_id: simulation_id,
             instance_name: instance_name,
             instance_number: instance_number,
             place_id: place_id,
             value: value
           })
         )}

      {
        :remove_token,
        _time_number,
        instance_name,
        instance_number,
        value,
        place_id
      } ->
        {:noreply,
         state
         |> State.append_command(
           RenewCollabSim.Commands.ConsumeToken.new(%{
             simulation_id: simulation_id,
             instance_name: instance_name,
             instance_number: instance_number,
             place_id: place_id,
             value: value
           })
         )}

      {
        :fire_transition,
        time_number,
        instance_name,
        instance_number,
        transition_id
      } ->
        {:noreply,
         state
         |> State.append_command(
           RenewCollabSim.Commands.FireTransition.new(%{
             simulation_id: simulation_id,
             shadow_net_system_id: simulation.shadow_net_system_id,
             instance_name: instance_name,
             instance_number: instance_number,
             transition_id: transition_id,
             time_number: time_number
           })
         )
         |> maybe_pause_at_breakpoint(instance_name, instance_number, transition_id)}

      {:timestep, time_number} ->
        state =
          state
          |> State.append_command(
            RenewCollabSim.Commands.StepTime.new(%{
              simulation_id: simulation_id,
              time_number: time_number
            })
          )
          |> State.commit(:strict)

        if playing and not scheduled do
          Process.send_after(self(), :auto_step, 100)

          {:noreply, %{state | scheduled: true} |> broadcast_change(:step)}
        else
          {:noreply, state |> broadcast_change(:step)}
        end

      :setup ->
        state
        |> State.append_command(
          RenewCollabSim.Commands.SetupSimulation.new(%{
            simulation_id: simulation_id
          })
        )
        |> State.commit(:strict)
        |> broadcast_change(:init)
        |> then(&{:noreply, &1})

      {:bindings_start, request_id, transition_id, transition_instance, count} ->
        {:noreply,
         update_in(
           state.binding_requests[request_id],
           &binding_request_started(&1, transition_id, transition_instance, count)
         )}

      {:binding, request_id, index, description} ->
        {:noreply,
         update_in(
           state.binding_requests[request_id],
           &binding_request_add_binding(&1, index, description)
         )}

      {:bindings_end, request_id} ->
        {:noreply, finish_binding_request(state, request_id)}

      {:bindings_error, request_id, detail} ->
        {:noreply, finish_binding_request_error(state, request_id, detail)}

      {:fire_result, request_id, "OK", _detail} ->
        {:noreply, finish_fire_request(state, request_id, :ok)}

      {:fire_result, request_id, "NO_BINDING", _detail} ->
        {:noreply, finish_fire_request(state, request_id, {:error, :no_enabled_binding})}

      {:fire_result, request_id, _status, detail} ->
        {:noreply, finish_fire_request(state, request_id, {:error, detail})}

      nil ->
        {:noreply, state}
    end
  end

  defp binding_request_started(nil, transition_id, transition_instance, count) do
    %{
      from: nil,
      transition_id: transition_id,
      transition_instance: transition_instance,
      expected_count: count,
      bindings: []
    }
  end

  defp binding_request_started(request, transition_id, transition_instance, count) do
    %{
      request
      | transition_id: transition_id,
        transition_instance: transition_instance,
        expected_count: count
    }
  end

  defp binding_request_add_binding(nil, index, description) do
    %{
      from: nil,
      transition_id: nil,
      transition_instance: nil,
      expected_count: nil,
      bindings: [{index, description}]
    }
  end

  defp binding_request_add_binding(request, index, description) do
    update_in(request.bindings, &[{index, description} | &1])
  end

  defp finish_binding_request(%{binding_requests: requests} = state, request_id) do
    case Map.get(requests, request_id) do
      %{from: from} = request ->
        bindings =
          request.bindings
          |> Enum.sort_by(fn {index, _description} -> index end)
          |> Enum.map(fn {_index, description} -> description end)

        if from,
          do:
            GenServer.reply(
              from,
              {:ok,
               %{
                 transition_id: request.transition_id,
                 transition_instance: request.transition_instance,
                 bindings: bindings
               }}
            )

        %{state | binding_requests: Map.delete(requests, request_id)}

      _ ->
        state
    end
  end

  defp finish_binding_request_error(%{binding_requests: requests} = state, request_id, detail) do
    case Map.get(requests, request_id) do
      %{from: from} ->
        if from, do: GenServer.reply(from, {:error, detail})
        %{state | binding_requests: Map.delete(requests, request_id)}

      _ ->
        state
    end
  end

  defp finish_fire_request(%{fire_requests: requests} = state, request_id, result) do
    case Map.get(requests, request_id) do
      %{from: from} ->
        if from, do: GenServer.reply(from, result)
        %{state | fire_requests: Map.delete(requests, request_id)}

      _ ->
        state
    end
  end

  defp maybe_pause_at_breakpoint(
         %{breakpoints: breakpoints} = state,
         instance_name,
         instance_number,
         transition_id
       ) do
    if Map.has_key?(breakpoints, transition_id) do
      net_instance_label = "#{instance_name}[#{instance_number}]"

      state
      |> then(&%{&1 | playing: false, scheduled: false})
      |> broadcast_breakpoint_hit(net_instance_label, transition_id)
    else
      state
    end
  end

  defp breakpoint_list(%{breakpoints: breakpoints}) do
    breakpoints
    |> Map.values()
    |> Enum.sort_by(& &1.transition_id)
  end

  @impl true
  # handle termination
  def terminate(
        _reason,
        %State{} = state
      ) do
    State.destroy(state)

    state |> broadcast_change(:stop)
  end

  defp maybe_remember_simulation_error(state, content) do
    content = String.trim(content)

    if content != "" and simulation_error_line?(content) do
      remember_simulation_error(state, content)
    else
      state
    end
  end

  defp simulation_error_line?(content) when is_binary(content) do
    String.contains?(content, ["Exception", "ERROR:", "Error occurred"])
  end

  defp simulation_error_line?(_content), do: false

  defp simulation_protocol_line?(content) when is_binary(content) do
    String.contains?(content, "SIMULATION_")
  end

  defp simulation_protocol_line?(_content), do: false

  defp maybe_broadcast_exit_error(%{last_error: error} = state, _status)
       when is_binary(error) or is_list(error) do
    case simulation_error_text(error) do
      "" -> state
      text -> broadcast_error(state, text)
    end
  end

  defp maybe_broadcast_exit_error(state, status) when status not in [nil, 0] do
    broadcast_error(state, "Simulation process exited with status #{status}")
  end

  defp maybe_broadcast_exit_error(state, _status), do: state

  defp remember_simulation_error(%{last_error: nil} = state, content) do
    %{state | last_error: [content]}
  end

  defp remember_simulation_error(%{last_error: error} = state, content) when is_binary(error) do
    remember_simulation_error(%{state | last_error: [error]}, content)
  end

  defp remember_simulation_error(%{last_error: errors} = state, content) when is_list(errors) do
    %{state | last_error: Enum.take(errors ++ [content], -8)}
  end

  defp simulation_error_text(errors) when is_list(errors) do
    errors
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
    |> Enum.join("\n")
  end

  defp simulation_error_text(error) when is_binary(error), do: String.trim(error)

  defp safe_call(pid, message) do
    GenServer.call(pid, message, @simulation_command_timeout)
  catch
    :exit, {:timeout, _} -> {:error, :simulation_command_timed_out}
    :exit, reason -> {:error, reason}
  end
end
