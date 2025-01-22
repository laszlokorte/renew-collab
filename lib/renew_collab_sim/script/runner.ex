defmodule RenewCollabSim.Script.Runner do
  def start_and_wait(script_path) do
    s = self()

    spawn_link(fn ->
      {result, _} = exec(["script", script_path])

      send(s, {:finished, result})
    end)

    receive do
      {:finished, result} ->
        {:ok, result}
    end
  end

  def check_status(cmd \\ ["packageCount"]) do
    s = self()

    spawn_link(fn ->
      {status, acc} = exec(cmd, nil, [])

      send(s, {:finished, status, Enum.reverse(acc)})
    end)

    receive do
      {:finished, status, output} ->
        {:ok, status, output}
    end
  end

  def start_and_collect(script_path, collector, acc \\ nil) do
    s = self()

    spawn_link(fn ->
      result = exec(["script", script_path], collector, acc)
      send(s, {:port, result})
    end)

    receive do
      {:port, result} ->
        result
    end
  end

  defp exec(renew_cmd, collector \\ nil, acc \\ nil) do
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

    port_config = [
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
          "de.renew.loader"
          | renew_cmd
        ]
        |> Enum.reject(&is_nil/1)
    ]

    if collector do
      slf = self()

      spawn_link(fn ->
        port =
          Port.open(
            {:spawn_executable, System.find_executable("java")},
            port_config
          )

        Process.link(port)

        Port.monitor(port)
        s = self()

        commander =
          spawn_link(fn ->
            read_loop(port, s)
          end)

        send(slf, {:commander, commander})

        handle_output(port, 0, collector, acc)
      end)

      receive do
        {:commander, commander} ->
          commander
      end
    else
      port =
        Port.open(
          {:spawn_executable, System.find_executable("java")},
          port_config
        )

      Process.link(port)

      Port.monitor(port)
      handle_output(port, 0, collector, acc)
    end
  end

  def handle_output(port, return \\ nil, collector \\ nil, acc \\ nil) do
    receive do
      {^port, {:data, "ERROR: " <> _d} = data} ->
        # dbg("ABC1")
        # dbg(data)
        handle_output(port, 1, collector, collect(collector, data, acc))

      {^port, {:data, "Error occurred" <> _d} = data} ->
        # dbg("ABC2")
        # dbg(data)
        handle_output(port, 1, collector, collect(collector, data, acc))

      {^port, {:data, data}} ->
        # dbg("ABC3")

        # dbg(data)
        # IO.write(data)
        handle_output(port, return, collector, collect(collector, data, acc))

      {^port, {:exit_status, status}} ->
        # dbg("ABC4")
        handle_output(port, status, collector, acc)

      {^port, :eof} ->
        collect(collector, {:exit, return}, acc)
        # dbg("EXIT1")
        {return, acc}

      {:EXIT, _, :normal} ->
        # dbg("EXIT2")
        {return, acc}

      e ->
        {:unexpected, e, acc}
    end
  end

  defp collect(nil, _, nil) do
    nil
  end

  defp collect(nil, data, acc) when is_list(acc) do
    [data | acc]
  end

  defp collect(func, data, acc) do
    func.(data, acc)
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
