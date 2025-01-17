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
    xvbf_path = Keyword.get(conf, :sim_xvbf_path)
    xvbf_display = Keyword.get(conf, :sim_xvbf_display)
    interceptor_path = Keyword.get(conf, :sim_interceptor_path)
    log_conf_path = Keyword.get(conf, :sim_log_conf_path)

    module_path = "#{renew_path}" <> separator <> "#{renew_path}/libs"

    # dbg(module_path)

    if collector do
      slf = self()

      spawn_link(fn ->
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
              line: 2048,
              env:
                if(xvbf_display,
                  do: [{to_charlist("DISPLAY"), to_charlist(xvbf_display)}],
                  else: []
                ),
              cd: "/tmp",
              args:
                [
                  "-jar",
                  interceptor_path,
                  if(xvbf_path, do: xvbf_path, else: nil),
                  "java",
                  "-Dde.renew.plugin=ERROR,nullAppender",
                  "-Dlog4j.appender.nullAppender=org.apache.log4j.varia.NullAppender",
                  "-Dlog4j.configuration=#{log_conf_path}",
                  "-Djline.terminal=off",
                  "-Dorg.jline.terminal.dumb=true",
                  "-Dde.renew.splashscreen.enabled=false",
                  "-Dde.renew.gui.autostart=false",
                  "-Dde.renew.simulatorMode=-1",
                  "-Dde.renew.plugin.autoLoad=false",
                  "-Dde.renew.plugin.load=Renew Util, Renew Simulator, Renew Formalism, Renew Misc, Renew PTChannel, Renew Remote, Renew Window Management, Renew JHotDraw, Renew Gui, Renew Formalism Gui, Renew Logging, Renew NetComponents, Renew Console, Renew FreeHep Export",
                  # "-Dlog4j.debug=true",
                  "-p",
                  module_path,
                  "-m",
                  "de.renew.loader",
                  "script",
                  script_path
                ]
                |> Enum.reject(&is_nil/1)
            ]
          )

        Process.link(port)

        Port.monitor(port)
        s = self()

        commander =
          spawn_link(fn ->
            read_loop(port, s)
          end)

        send(slf, {:commander, commander})

        handle_output(port, 0, collector)
      end)

      receive do
        {:commander, commander} ->
          commander
      end
    else
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
            line: 2048,
            env:
              if(xvbf_display,
                do: [{to_charlist("DISPLAY"), to_charlist(xvbf_display)}],
                else: []
              ),
            cd: "/tmp",
            args:
              [
                "-jar",
                interceptor_path,
                if(xvbf_path, do: xvbf_path, else: nil),
                "java",
                "-Dde.renew.plugin=ERROR,nullAppender",
                "-Dlog4j.appender.nullAppender=org.apache.log4j.varia.NullAppender",
                "-Dlog4j.configuration=#{log_conf_path}",
                "-Djline.terminal=off",
                "-Dorg.jline.terminal.dumb=true",
                "-Dde.renew.splashscreen.enabled=false",
                "-Dde.renew.gui.autostart=false",
                "-Dde.renew.simulatorMode=-1",
                "-Dde.renew.plugin.autoLoad=false",
                "-Dde.renew.plugin.load=Renew Util, Renew Simulator, Renew Formalism, Renew Misc, Renew PTChannel, Renew Remote, Renew Window Management, Renew JHotDraw, Renew Gui, Renew Formalism Gui, Renew Logging, Renew NetComponents, Renew Console, Renew FreeHep Export",
                # "-Dlog4j.debug=true",
                "-p",
                module_path,
                "-m",
                "de.renew.loader",
                "script",
                script_path
              ]
              |> Enum.reject(&is_nil/1)
          ]
        )

      Process.link(port)

      Port.monitor(port)
      handle_output(port, 0, collector)
    end
  end

  def handle_output(port, return \\ nil, collector \\ nil) do
    receive do
      {^port, {:data, "ERROR: " <> _d} = data} ->
        # dbg("ABC1")
        collect(collector, data)
        # dbg(data)
        handle_output(port, 1, collector)

      {^port, {:data, "Error occurred" <> _d} = data} ->
        # dbg("ABC2")
        collect(collector, data)
        # dbg(data)
        handle_output(port, 1, collector)

      {^port, {:data, data}} ->
        # dbg("ABC3")
        collect(collector, data)
        # dbg(data)
        # IO.write(data)
        handle_output(port, return, collector)

      {^port, {:exit_status, status}} ->
        # dbg("ABC4")
        handle_output(port, status, collector)

      {^port, :eof} ->
        collect(collector, {:exit, return})
        # dbg("EXIT1")
        return

      {:EXIT, _, :normal} ->
        # dbg("EXIT2")
        return

      e ->
        {:unexpected, e}
    end
  end

  defp collect(nil, _) do
  end

  defp collect(func, data) do
    func.(data)
  end

  defp read_loop(port, s) do
    receive do
      {:command, cmd} ->
        # dbg(cmd)
        send(port, {s, {:command, cmd}})
        read_loop(port, s)

      msg ->
        raise {:unexpected, msg}
    end
  end
end
