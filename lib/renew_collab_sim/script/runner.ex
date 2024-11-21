defmodule RenewCollabSim.Script.Runner do
  def start(script_path) do
    p =
      spawn_link(fn ->
        run(script_path)
      end)
  end

  def start_and_wait(script_path) do
    s = self()

    p =
      spawn_link(fn ->
        result = run(script_path)

        send(s, {:finished, result})
      end)

    receive do
      {:finished, result} ->
        {:ok, result}
    end
  end

  def run(script_path) do
    separator =
      case :os.type() do
        {:win32, _} -> ";"
        {:unix, _} -> ":"
      end

    renew_path = "C:/Users/Laszlo/Desktop/eigene-projekte/renew-sim-script"
    interceptor_path = "#{renew_path}/Interceptor.jar"

    log_conf_path =
      "C:/Users/Laszlo/Desktop/eigene-projekte/renew_collab/priv/simulation/log4j.properties"

    module_path = "#{renew_path}/renew41" <> separator <> "#{renew_path}/renew41/libs"

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

    handle_output(port, 0)
  end

  def handle_output(port, return \\ nil) do
    receive do
      {^port, {:data, "ERROR: " <> d = data}} ->
        # IO.write(data)
        handle_output(port, 1)

      {^port, {:data, data}} ->
        # dbg(data)
        # IO.write(data)
        handle_output(port, return)

      {^port, {:exit_status, status}} ->
        handle_output(port, return)

      {^port, :eof} ->
        return

      {:EXIT, _, :normal} ->
        return

      e ->
        dbg("unexpected")
        dbg(port)
        dbg(e)
    end
  end
end
