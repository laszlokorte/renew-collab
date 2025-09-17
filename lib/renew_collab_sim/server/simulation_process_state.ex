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
    :open_multi,
    :cmds
  ]

  def init(simulation) do
    try do
      import Ecto.Query

      conf = Application.fetch_env!(:renew_collab, RenewCollabSim.Commands)

      cmds = %{
        sim_start: Keyword.get(conf, :sim_start),
        sim: Keyword.get(conf, :sim),
        sim_step: Keyword.get(conf, :sim_step)
      }

      {sim_process, directory} = init_process(simulation, Map.get(cmds, :sim_start))

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
         logging: true,
         cmds: cmds,
         open_multi:
           {0,
            Ecto.Multi.new()
            |> Ecto.Multi.delete_all(
              :reset_net_instances_initial,
              from(n in RenewCollabSim.Entites.SimulationNetInstance,
                where: n.simulation_id == ^simulation.id
              )
            )
            |> Ecto.Multi.delete_all(
              :reset_logs_initial,
              from(l in RenewCollabSim.Entites.SimulationLogEntry,
                where: l.simulation_id == ^simulation.id
              )
            )
            |> Ecto.Multi.update_all(
              :reset_timestep_initial,
              from(sim in RenewCollabSim.Entites.Simulation,
                where: sim.id == ^simulation.id,
                update: [set: [timestep: 0]]
              ),
              []
            )}
       }}
    rescue
      _ ->
        :error
    end
  end

  defp init_process(simulation, start_command) do
    slf = self()
    uuid_dir = "renew-simulation-#{simulation.id}/#{UUID.uuid4(:default)}"

    {:ok, output_root} = Path.safe_relative_to(uuid_dir, System.tmp_dir!())
    output_root = Path.absname(output_root, System.tmp_dir!())

    {:ok, sns_path} = Path.safe_relative_to("compiled-shadow-net.ssn", output_root)
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
        GenServer.cast(slf, {:log, log})
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

  def append_command(
        state = %{open_multi: {om_counter, open_multi}},
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
    open_multi |> Repo.transaction()
    %{state | open_multi: {0, Ecto.Multi.new()}}
  end

  def commit(%{open_multi: {_, open_multi}} = state, :try) do
    try do
      open_multi |> Repo.transaction()
    rescue
      Ecto.ConstraintError -> {}
    end

    %{state | open_multi: {0, Ecto.Multi.new()}}
  end
end
