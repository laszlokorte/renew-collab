defmodule RenewCollabSim.Server.SimulationParser do
  @prompt "Renew > "

  @new_instance ~r/\((?<ni_time_number>\d+)\)New net instance (?<ni_instance_name>[^\[]+)\[(?<ni_instance_number>\d+)\] created\./
  @init_token ~r/\((?<it_time_number>\d+)\)Initializing (?<it_value>.+) into (?<it_instance_name>[^\[]+)\[(?<it_instance_number>\d+)\].(?<it_place_id>\S+)/
  @putting ~r/\((?<pt_time_number>\d+)\)Putting (?<pt_value>.+) into (?<pt_instance_name>[^\[]+)\[(?<pt_instance_number>\d+)\].(?<pt_place_id>\S+)/
  @removing ~r/\((?<rm_time_number>\d+)\)Removing (?<rm_value>.+) in (?<rm_instance_name>[^\[]+)\[(?<rm_instance_number>\d+)\].(?<rm_place_id>\S+)/
  @firing ~r/\((?<fr_time_number>\d+)\)Firing (?<fr_instance_name>[^\[]+)\[(?<fr_instance_number>\d+)\].(?<fr_transition_id>\S+)/
  @sync ~r/\((?<sc_time_number>\d+)\)-------- Synchronously --------/
  @setup ~r/(?<setup>Simulation set up,\s+)/

  @combined [@new_instance, @init_token, @putting, @removing, @firing, @sync, @setup]
            |> Enum.map(& &1.source)
            |> Enum.join("|")
            |> then(&"(:?#{@prompt})?(?:#{&1})")
            |> Regex.compile!("um")

  def parse(line) do
    Regex.named_captures(@combined, line)
    |> case do
      %{
        "ni_time_number" => time_number,
        "ni_instance_name" => instance_name,
        "ni_instance_number" => instance_number
      }
      when "" != time_number ->
        {:new_instance, time_number, instance_name, instance_number}

      %{
        "it_time_number" => time_number,
        "it_instance_name" => instance_name,
        "it_instance_number" => instance_number,
        "it_value" => value,
        "it_place_id" => place_id
      }
      when "" != time_number ->
        {:init_token, time_number, instance_name, instance_number, value, place_id}

      %{
        "pt_time_number" => time_number,
        "pt_instance_name" => instance_name,
        "pt_instance_number" => instance_number,
        "pt_value" => value,
        "pt_place_id" => place_id
      }
      when "" != time_number ->
        {
          :put_token,
          time_number,
          instance_name,
          instance_number,
          value,
          place_id
        }

      %{
        "rm_time_number" => time_number,
        "rm_instance_name" => instance_name,
        "rm_instance_number" => instance_number,
        "rm_value" => value,
        "rm_place_id" => place_id
      }
      when "" != time_number ->
        {
          :remove_token,
          time_number,
          instance_name,
          instance_number,
          value,
          place_id
        }

      %{
        "fr_time_number" => time_number,
        "fr_instance_name" => instance_name,
        "fr_instance_number" => instance_number,
        "fr_transition_id" => transition_id
      }
      when "" != time_number ->
        {
          :fire_transition,
          time_number,
          instance_name,
          instance_number,
          transition_id
        }

      %{
        "sc_time_number" => time_number
      }
      when "" != time_number ->
        {:timestep, time_number}

      %{
        "setup" => setup
      }
      when "" != setup ->
        :setup

      nil ->
        nil
    end
  end
end
