defmodule RenewCollabSim.Server.SimulationProcess do
  use GenServer

  alias RenewCollabSim.Server.SimulationProcess.State

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

  defp simulation_error_payload(detail) do
    %{
      error: "simulation_process_failed",
      title: "Simulation Error",
      message: "Renew stopped the simulation before it could be initialized.",
      detail: explain_simulation_error(detail)
    }
  end

  defp explain_simulation_error(detail) when is_binary(detail) do
    cond do
      String.contains?(detail, "Transitions may not carry inscriptions") ->
        "Renew reported: #{detail}. This means that at least one transition has an inscription that Renew does not accept for simulation. Remove that inscription from the transition, or move it to a supported net element, then create or initialize the simulation again."

      true ->
        "Renew reported: #{detail}"
    end
  end

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
  def handle_cast(:play, state) do
    State.step(state)
    {:noreply, %{state | playing: true}}
  end

  @impl true
  def handle_cast(:pause, %{sim_process: _sim_process} = state) do
    # send(sim_process, {:command, "simulation stop\n"})
    {:noreply, %{state | playing: false}}
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
      if logging and not playing do
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
      if logging and not playing do
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
         )}

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

      nil ->
        {:noreply, state}
    end
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
    if simulation_error_line?(content) do
      %{state | last_error: String.trim(content)}
    else
      state
    end
  end

  defp simulation_error_line?(content) when is_binary(content) do
    String.contains?(content, ["Exception", "ERROR:", "Error occurred"])
  end

  defp simulation_error_line?(_content), do: false

  defp maybe_broadcast_exit_error(%{last_error: error} = state, _status)
       when is_binary(error) and error != "" do
    broadcast_error(state, error)
  end

  defp maybe_broadcast_exit_error(state, status) when status not in [nil, 0] do
    broadcast_error(state, "Simulation process exited with status #{status}")
  end

  defp maybe_broadcast_exit_error(state, _status), do: state
end
