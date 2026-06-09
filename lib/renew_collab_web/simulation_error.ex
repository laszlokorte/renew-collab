defmodule RenewCollabWeb.SimulationError do
  def payload(error, message, reason) do
    %{
      error: error,
      message: message,
      detail: detail(reason)
    }
  end

  def format(reason, fallback) do
    [fallback, detail(reason)]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
    |> Enum.join("\n\n")
  end

  def detail(nil), do: nil

  def detail(%{message: message, detail: detail}) when not is_nil(detail) do
    [message, detail(detail)]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
    |> Enum.join("\n\n")
  end

  def detail(%{"message" => message, "detail" => detail}) when not is_nil(detail) do
    [message, detail(detail)]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
    |> Enum.join("\n\n")
  end

  def detail(%{detail: detail}) when not is_nil(detail), do: detail(detail)
  def detail(%{"detail" => detail}) when not is_nil(detail), do: detail(detail)
  def detail(:error), do: "The simulation process could not be started."
  def detail(:ignore), do: "The simulation process could not be started."

  def detail(:compile_timed_out),
    do: "Renew did not finish compiling the shadow net system in time."

  def detail(:no_documents), do: "No document was selected for simulation."
  def detail(:invalid_rnw), do: "The document is not a valid Renew file."
  def detail(:export_rnw), do: "Conversion to Renew format failed."
  def detail(:access), do: "You do not have permission to perform this action."

  def detail(:no_enabled_binding),
    do: "The selected transition has no enabled binding in the current marking."

  def detail(:simulation_command_timed_out),
    do: "Renew did not answer the simulation command in time."

  def detail({:compile_failed, status, output}) do
    status_text =
      case status do
        nil -> "Renew did not report an exit status."
        status -> "Renew exited with status #{status} while compiling the shadow net system."
      end

    [status_text, output_text(output)]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join("\n\n")
  end

  def detail({:dup, names}) when is_list(names) do
    "Duplicate net names: #{Enum.join(names, ", ")}"
  end

  def detail({:formalism, formalism}) do
    "Unknown formalism: #{formalism}"
  end

  def detail({:export_error, error}) do
    "PetriStation could not export the document to Renew format: #{detail(error)}"
  end

  def detail({:error, reason}), do: detail(reason)
  def detail({:stop, reason}), do: detail(reason)

  def detail(%{__exception__: true} = error) do
    Exception.message(error)
  end

  def detail(reason) when is_binary(reason), do: reason
  def detail(reason), do: inspect(reason)

  defp output_text(output) when is_list(output) do
    output
    |> Enum.map(&output_item_text/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
    |> Enum.join("\n")
  end

  defp output_text(output) when is_binary(output), do: String.trim(output)
  defp output_text(_output), do: nil

  defp output_item_text(item) when is_binary(item), do: item
  defp output_item_text(item), do: inspect(item)
end
