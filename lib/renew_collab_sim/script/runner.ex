defmodule RenewCollabSim.Script.Runner do
  def start_and_wait(script_path) do
    s = self()

    spawn_link(fn ->
      result = exec(script_path)

      send(s, {:finished, result})
    end)

    receive do
      {:finished, result} ->
        {:ok, result}
    end
  end

  def start_and_collect(script_path, collector) do
    s = self()

    spawn_link(fn ->
      result = exec(script_path, collector)
      send(s, {:port, result})
    end)

    receive do
      {:port, result} ->
        result
    end
  end

  defp exec(script_path, collector \\ nil) do
    separator =
      case :os.type() do
        {:win32, _} -> ";"
        {:unix, _} -> ":"
      end

    conf = Application.fetch_env!(:renew_collab, RenewCollabSim.Script.Runner)

    renew_path = Keyword.get(conf, :sim_renew_path)
    interceptor_path = Keyword.get(conf, :sim_interceptor_path)
    log_conf_path = Keyword.get(conf, :sim_log_conf_path)

    module_path = "#{renew_path}" <> separator <> "#{renew_path}/libs"

    # dbg(module_path)

    port =
      Port.open(
        {:spawn_executable, System.find_executable("java")},
        [
          :binary,
          :eof,
          :stream,
          :stderr_to_stdout,
          :exit_status,
          :use_stdio,
          :hide,
          args: [
            "-jar",
            interceptor_path,
            "java",
            "-Djline.terminal=off",
            "-Dde.renew.splashscreen.enabled=false",
            "-Dde.renew.gui.autostart=false",
            "-Dde.renew.simulatorMode=-1",
            "-Dlog4j.configuration=#{log_conf_path}",
            "-Dde.renew.plugin.autoLoad=false",
            "-Dde.renew.plugin.load=Renew Util, Renew Simulator, Renew Formalism, Renew Misc, Renew PTChannel, Renew Remote, Renew Window Management, Renew JHotDraw, Renew Gui, Renew Formalism Gui, Renew Logging, Renew NetComponents, Renew Console, Renew FreeHep Export",
            "-p",
            module_path,
            "-m",
            "de.renew.loader",
            "script",
            script_path
          ]
        ]
      )

    Process.link(port)

    Port.monitor(port)
    s = self()

    if collector do
      spawn(fn ->
        handle_output(port, 0, collector)
      end)

      spawn(fn ->
        receive do
          {:command, cmd} ->
            dbg(cmd)
            send(port, {s, {:command, cmd}})
        end
      end)
    else
      Process.link(port)

      Port.monitor(port)
      handle_output(port, 0, collector)
    end
  end

  def handle_output(port, return \\ nil, collector \\ nil) do
    receive do
      {^port, {:data, "ERROR: " <> _d} = data} ->
        collect(collector, data)
        # dbg(data)
        handle_output(port, 1, collector)

      {^port, {:data, "Error occurred" <> _d} = data} ->
        collect(collector, data)
        # dbg(data)
        handle_output(port, 1, collector)

      {^port, {:data, data}} ->
        collect(collector, data)
        # dbg(data)
        # IO.write(data)
        handle_output(port, return, collector)

      {^port, {:exit_status, status}} ->
        handle_output(port, status, collector)

      {^port, :eof} ->
        dbg("EXIT")
        return

      {:EXIT, _, :normal} ->
        dbg("EXIT")
        return

      e ->
        dbg("unexpected")
        dbg(port)
        dbg(e)
    end
  end

  defp collect(nil, _) do
  end

  defp collect(func, data) do
    func.(data)
  end
end
