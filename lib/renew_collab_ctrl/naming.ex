defmodule RenewCollabCtrl.Naming do
  def name_for_copy(name) do
    cond do
      Regex.match?(~r/^(.*) \(Copy (\d+)\)$/, name) ->
        Regex.replace(~r/^(.*) \(Copy (\d+)\)$/, name, fn _, base, n ->
          "#{base} (Copy #{String.to_integer(n) + 1})"
        end)

      String.ends_with?(name, " (Copy)") ->
        String.replace_suffix(name, " (Copy)", "") <> " (Copy 2)"

      true ->
        name <> " (Copy)"
    end
  end
end
