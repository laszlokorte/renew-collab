defmodule RenewCollabSim.Server.SimulationProcess.State do
  alias RenewCollabSim.Repo

  defstruct [
    :simulation,
    :simulation_id,
    :sim_process,
    :directory,
    :latest_update,
    :retry,
    :playing,
    :scheduled,
    :logging,
    :last_error,
    :binding_requests,
    :fire_requests,
    :console_requests,
    :breakpoints,
    :open_multi,
    :throttle,
    :pubsub_channels,
    :cmds
  ]

  def init(parent, simulation, pubsub_channels, opts \\ []) do
    try do
      import Ecto.Query

      conf = Application.fetch_env!(:renew_collab, RenewCollabSim.Commands)

      cmds = %{
        sim_start: Keyword.get(conf, :sim_start),
        sim: Keyword.get(conf, :sim),
        sim_step: Keyword.get(conf, :sim_step),
        sim_net_step: Keyword.get(conf, :sim_net_step, "netstep"),
        sim_bindings: Keyword.get(conf, :sim_bindings, "bindings"),
        sim_fire: Keyword.get(conf, :sim_fire, "fire")
      }

      {sim_process, directory} = init_process(parent, simulation, Map.get(cmds, :sim_start))

      reset_multi =
        Ecto.Multi.new()
        |> Ecto.Multi.delete_all(
          :reset_net_instances_initial,
          from(n in RenewCollabSim.Entities.SimulationNetInstance,
            where: n.simulation_id == ^simulation.id
          )
        )
        |> Ecto.Multi.delete_all(
          :reset_logs_initial,
          from(l in RenewCollabSim.Entities.SimulationLogEntry,
            where: l.simulation_id == ^simulation.id
          )
        )
        |> Ecto.Multi.update_all(
          :reset_timestep_initial,
          from(sim in RenewCollabSim.Entities.Simulation,
            where: sim.id == ^simulation.id,
            update: [set: [timestep: 0]]
          ),
          []
        )

      # by default delete all net instances, log entries of older simulation runs from DB
      # and reset timer
      if Keyword.get(opts, :initial_reset, true) do
        Repo.transact(reset_multi)
      end

      {:ok,
       %__MODULE__{
         simulation: simulation,
         simulation_id: simulation.id,
         sim_process: sim_process,
         directory: directory,
         latest_update: nil,
         retry: nil,
         playing: false,
         scheduled: false,
         pubsub_channels: pubsub_channels,
         throttle: {100, :millisecond},
         logging: true,
         last_error: nil,
         binding_requests: %{},
         fire_requests: %{},
         console_requests: %{},
         breakpoints: %{},
         cmds: cmds,
         # rerun reset on first received event again
         open_multi: {0, reset_multi}
       }}
    rescue
      e ->
        {:error, e}
    end
  end

  defp init_process(parent, simulation, start_command) do
    uuid_dir = "petristation/renew-simulation-#{simulation.id}/#{UUID.uuid4(:default)}"

    {:ok, output_root} = Path.safe_relative_to(uuid_dir, System.tmp_dir!())
    output_root = Path.absname(output_root, System.tmp_dir!())

    {:ok, sns_path} = Path.safe_relative_to("compiled-shadow-net.sns", output_root)
    {:ok, script_path} = Path.safe_relative_to("simulation-script", output_root)

    sns_path = Path.absname(sns_path, output_root)
    script_path = Path.absname(script_path, output_root)

    File.mkdir_p(output_root)

    script_content =
      [
        "#{start_command} \"#{sns_path}\" \"#{simulation.shadow_net_system.main_net_name}\" -i"
      ]
      |> Enum.join("\n")

    File.write!(script_path, script_content)
    File.write!(sns_path, simulation.shadow_net_system.compiled)

    sim_process =
      RenewCollabSim.Script.Runner.start_and_collect(script_path, fn log, _ ->
        GenServer.cast(parent, {:log, log})
        nil
      end)

    {sim_process, output_root}
  end

  def destroy(%__MODULE__{sim_process: sim_process, directory: directory}) do
    Process.exit(sim_process, :kill)
    File.rm_rf(directory)
  end

  def step(%__MODULE__{sim_process: sim_process, cmds: %{sim: sim_cmd, sim_step: sim_cmd_step}}) do
    send(sim_process, {:command, "#{sim_cmd} #{sim_cmd_step}\n"})
  end

  def net_step(
        %__MODULE__{
          sim_process: sim_process,
          cmds: %{sim: sim_cmd, sim_net_step: sim_cmd_net_step}
        },
        net_instance_label
      ) do
    send(
      sim_process,
      {:command, "#{sim_cmd} #{sim_cmd_net_step} #{quote_arg(net_instance_label)}\n"}
    )
  end

  # The user command is wrapped between two `get <marker>` commands. The console
  # processes stdin commands sequentially on its prompt thread, so the begin/end
  # markers are echoed in order around the genuine command response. `get` for an
  # unset property echoes the marker token ("Property <marker> is not set."),
  # which lets the server delimit the response deterministically instead of
  # guessing via a fixed time window — even while simulation output interleaves.
  def console_command(%__MODULE__{sim_process: sim_process}, begin_marker, command, end_marker)
      when is_binary(command) do
    send(sim_process, {:command, "get #{begin_marker}\n"})
    send(sim_process, {:command, String.trim_trailing(command) <> "\n"})
    send(sim_process, {:command, "get #{end_marker}\n"})
  end

  def transition_bindings(
        %__MODULE__{
          sim_process: sim_process,
          cmds: %{sim: sim_cmd, sim_bindings: sim_cmd_bindings}
        },
        request_id,
        net_instance_label,
        transition_id
      ) do
    send(
      sim_process,
      {:command,
       "#{sim_cmd} #{sim_cmd_bindings} #{request_id} #{quote_arg(net_instance_label)} #{quote_arg(transition_id)}\n"}
    )
  end

  def fire_transition(
        %__MODULE__{
          sim_process: sim_process,
          cmds: %{sim: sim_cmd, sim_fire: sim_cmd_fire}
        },
        request_id,
        net_instance_label,
        transition_id,
        binding_index
      ) do
    binding_arg =
      if is_nil(binding_index) do
        ""
      else
        " #{binding_index}"
      end

    send(
      sim_process,
      {:command,
       "#{sim_cmd} #{sim_cmd_fire} #{request_id} #{quote_arg(net_instance_label)} #{quote_arg(transition_id)}#{binding_arg}\n"}
    )
  end

  defp quote_arg(value) do
    escaped =
      value
      |> to_string()
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")

    "\"#{escaped}\""
  end

  def append_command(
        %{open_multi: {om_counter, open_multi}} = state,
        %{__struct__: module} = command
      ) do
    new_multi =
      module
      |> apply(:multi, [command, om_counter])
      |> Ecto.Multi.prepend(open_multi)

    %{state | open_multi: {om_counter + 1, new_multi}}
  end

  def commit(state, mode \\ :strict)

  def commit(%{open_multi: {_, open_multi}} = state, :strict) do
    open_multi |> Repo.transact()
    %{state | open_multi: {0, Ecto.Multi.new()}}
  end

  def commit(%{open_multi: {_, open_multi}} = state, :try) do
    try do
      open_multi |> Repo.transact()
    rescue
      Ecto.ConstraintError -> {}
      FunctionClauseError -> {}
    end

    %{state | open_multi: {0, Ecto.Multi.new()}}
  end
end
