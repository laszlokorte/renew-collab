defmodule RenewCollabSim.Server.SimulationParser do
  @prompt "Renew > "

  @new_instance ~r/\((?<ni_time_number>\d+)\)New net instance (?<ni_instance_name>[^\[]+)\[(?<ni_instance_number>\d+)\] created\./
  @init_token ~r/\((?<it_time_number>\d+)\)Initializing (?<it_value>.+) into (?<it_instance_name>[^\[]+)\[(?<it_instance_number>\d+)\].(?<it_place_id>\S+)/
  @putting ~r/\((?<pt_time_number>\d+)\)Putting (?<pt_value>.+) into (?<pt_instance_name>[^\[]+)\[(?<pt_instance_number>\d+)\].(?<pt_place_id>\S+)/
  @removing ~r/\((?<rm_time_number>\d+)\)Removing (?<rm_value>.+) in (?<rm_instance_name>[^\[]+)\[(?<rm_instance_number>\d+)\].(?<rm_place_id>\S+)/
  @firing ~r/\((?<fr_time_number>\d+)\)Firing (?<fr_instance_name>[^\[]+)\[(?<fr_instance_number>\d+)\].(?<fr_transition_id>\S+)/
  @sync ~r/\((?<sc_time_number>\d+)\)-------- Synchronously --------/
  @setup ~r/(?<setup>Simulation set up,\s+)/
  @bindings_start ~r/PETRISTATION_BINDINGS (?<bs_request_id>\S+) (?<bs_transition_id>\S+)(?: (?<bs_transition_instance>\S+))? (?<bs_count>\d+)/
  @binding ~r/PETRISTATION_BINDING (?<bd_request_id>\S+) (?<bd_index>\d+) (?<bd_description>\S+)/
  @bindings_end ~r/PETRISTATION_BINDINGS_END (?<be_request_id>\S+)/
  @bindings_error ~r/PETRISTATION_BINDINGS_ERROR (?<ber_request_id>\S+) (?<ber_detail>\S+)/
  @fire_result ~r/PETRISTATION_FIRE (?<fire_request_id>\S+) (?<fire_status>\S+)(?: (?<fire_detail>\S+))?/

  @combined [
              @bindings_start,
              @binding,
              @bindings_end,
              @bindings_error,
              @fire_result,
              @new_instance,
              @init_token,
              @putting,
              @removing,
              @firing,
              @sync,
              @setup
            ]
            |> Enum.map_join("|", & &1.source)
            |> then(&"(:?#{@prompt})?(?:#{&1})")
            |> Regex.compile!("um")

  def parse(line) do
    Regex.named_captures(@combined, line)
    |> case do
      %{
        "bs_request_id" => request_id,
        "bs_transition_id" => transition_id,
        "bs_transition_instance" => transition_instance,
        "bs_count" => count
      }
      when "" != request_id ->
        {:bindings_start, request_id, decode(transition_id), decode(transition_instance),
         String.to_integer(count)}

      %{
        "bd_request_id" => request_id,
        "bd_index" => index,
        "bd_description" => description
      }
      when "" != request_id ->
        {:binding, request_id, String.to_integer(index), decode(description)}

      %{
        "be_request_id" => request_id
      }
      when "" != request_id ->
        {:bindings_end, request_id}

      %{
        "ber_request_id" => request_id,
        "ber_detail" => detail
      }
      when "" != request_id ->
        {:bindings_error, request_id, decode(detail)}

      %{
        "fire_request_id" => request_id,
        "fire_status" => status,
        "fire_detail" => detail
      }
      when "" != request_id ->
        {:fire_result, request_id, status, decode(detail)}

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

  defp decode(nil), do: nil
  defp decode(""), do: nil

  defp decode(value) do
    case Base.decode64(value) do
      {:ok, decoded} -> decoded
      :error -> value
    end
  end
end
