defmodule RenewCollabWeb.HealthController do
  use RenewCollabWeb, :controller
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  action_fallback RenewCollabWeb.FallbackController

  # timelimit in miliseconds
  @renew_cmd_timelimit 5000

  def index(conn, _params) do
    render(
      conn,
      :index,
      %Views.SystemHealthReport{}
      |> Fetcher.fetch_as(conn.assigns.current_account)
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
