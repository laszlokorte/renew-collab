defmodule RenewCollab.TextMeasure.MeasureServer do
  use GenServer

  def measure(text) do
    GenServer.call(__MODULE__, {:measure, text})
  end

  def start_link(_defaults) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    conf = Application.fetch_env!(:renew_collab, RenewCollab.TextMeasure.MeasureServer)

    try do
      p =
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
            args:
              [
                Keyword.get(conf, :script)
              ]
              |> Enum.reject(&is_nil/1)
          ]
        )

      Process.link(p)

      {:ok, %{port: p, clients: :queue.new()}}
    rescue
      _ ->
        :ignore
    end
  end

  @impl true
  def handle_info(
        {port, {:data, {:eol, answer}}},
        %{port: port, clients: clients} = state
      ) do
    {{:value, client}, rem_clients} = :queue.out_r(clients)
    [width, height] = String.split(answer, ":")
    GenServer.reply(client, {String.to_integer(width), String.to_integer(height)})
    {:noreply, %{state | clients: rem_clients}}
  end

  @impl true
  def handle_call(
        {:measure, {font, style, size, lines}},
        from,
        %{port: port, clients: clients} = state
      )
      when is_binary(font) and is_integer(style) and is_integer(size) and is_list(lines) do
    joined_text = lines |> Enum.map(&:uri_string.quote(&1)) |> Enum.join(":") |> dbg
    Port.command(port, "#{java_font_name(font)}:#{style}:#{size}:#{joined_text}\n")

    {:noreply, %{state | clients: :queue.in(from, clients)}}
  end

  @impl true
  def handle_call(
        {:measure, {font, style, size, lines}},
        from,
        %{port: port, clients: clients} = state
      )
      when is_binary(font) and is_integer(style) and is_float(size) and is_list(lines) do
    joined_text = lines |> Enum.map(&:uri_string.quote(&1)) |> Enum.join(":") |> dbg
    Port.command(port, "#{java_font_name(font)}:#{style}:#{round(size)}:#{joined_text}\n")

    {:noreply, %{state | clients: :queue.in(from, clients)}}
  end

  @impl true
  # handle termination
  def terminate(
        _reason,
        %{port: port}
      ) do
    Process.exit(port, :kill)
  end

  defp java_font_name("sans-serif"), do: "Helvetica"
  defp java_font_name("serif"), do: "TimesRoman"
  defp java_font_name("monospace"), do: "Courier"

  defp java_font_name(font) do
    font
  end
end
