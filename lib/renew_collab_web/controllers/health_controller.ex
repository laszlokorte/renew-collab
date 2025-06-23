defmodule RenewCollabWeb.HealthController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  # timelimit in miliseconds
  @renew_cmd_timelimit 5000

  def index(conn, _params) do
    render(conn, :index,
      installed_socke_schema: RenewCollab.Sockets.all_socket_schemas(),
      installed_symbols: RenewCollab.Symbols.ids_by_name(),
      number_of_accounts: RenewCollabAuth.Auth.count_accounts(),
      number_of_sessions: RenewCollabAuth.Auth.count_sessions(),
      number_of_media: RenewCollab.Media.count(),
      number_of_documents: RenewCollab.Renew.count_documents(),
      number_of_projects: RenewCollabProj.Projects.count_projects(),
      hierarchy_missing_count: RenewCollab.Hierarchy.count_missing_global(),
      hierarchy_invalid_count: RenewCollab.Hierarchy.count_invalids_global(),
      cache_size: RenewCollab.SimpleCache.size(),
      simulation_count: RenewCollabSim.Server.SimulationServer.count(),
      formalisms: RenewCollabSim.Compiler.SnsCompiler.formalisms()
    )
  end

  def simulator(conn, params) do
    command = Map.get(params, "renew_command", "help") |> String.split(" ")

    RenewCollabSim.Script.Runner.check_status(command, @renew_cmd_timelimit)
    |> case do
      {:ok, status, output} ->
        render(conn, :simulator, %{
          status: status,
          output: output,
          current_command: command
        })

      :timedout ->
        render(conn, :simulator, %{
          status: -1,
          output: [{:eol, "Timeout: Running the command took longer than expected"}],
          current_command: command
        })
    end
  end
end
